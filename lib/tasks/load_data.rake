# frozen_string_literal: true

require 'rubyXL'
require 'rake'
require 'google_drive'
require 'google/cloud/storage'
require 'uri'

namespace :db do
  namespace :load do
    task :before_hook do
      google_drive_session
      download_excel_from_google_drive
    end

    task tables: :environment do
      reset_tables
      load_data
      product_item_update
    end

    task images_and_documents: :environment do
      reset_images_and_files
      process_item_image
      process_client_images
      process_product_images
      process_product_documents
      sh 'rm config/google_storage_config.json'
      sh 'rm config/google_drive_config.json'
    end

    tasks = Rake.application.tasks.select do |task|
      task if ['db:load:tables', 'db:load:images_and_documents'].include?(task.to_s)
    end
    tasks.each {|task| task.enhance [:before_hook] }

    private

    def product_item_update
      Product.where.not(subitem: nil).each do |product|
        product.update(item: product.subitem.item)
      end
    end

    def process_product_documents
      print "Seeding product documents..."
      select_sheet('product') do |product_params|
        next if product_params[:files].blank?

        documents = product_params[:files].split(',').map {|a| a.gsub('/','_').strip }
        product = Product.find(product_params[:id])
        documents.each {|document| attach_document(document, product) }
      rescue StandardError => e
        puts e
      end
    end

    def process_product_images
      print "Seeding product images..."
      select_sheet('product') do |product_params|
        next if product_params[:images].blank?

        images = product_params[:images].split(',').map {|a| a.gsub('/','_').strip }
        product = Product.find(product_params[:id])
        images.each_with_index {|image, index| attach_image(image, product, 'product_image', index) }
      rescue StandardError => e
        puts e
      end
    end

    def process_item_image
      select_sheet('item') do |item_params|
        next if item_params[:images].blank?

        images = item_params[:images].split(',').map {|a| a.gsub('/','_').strip }
        item = Item.find(item_params[:id])
        images.each_with_index {|image, index| attach_image(image, item, 'item_image', index) }
      rescue StandardError => e
        puts e
      end
    end

    def process_client_images
      print "Seeding client images..."
      select_sheet('client') do |client_params|
        company = client_params[:type] == 'Client' ? Company::Client.find(client_params[:id]) : Company::Brand.find(client_params[:id])
        client_logo(company, client_params)
        client_show_images(company, client_params)
      rescue StandardError => e
        puts e
      end
      puts 'done'
    end

    def select_sheet(sheet_name)
      resources = @excel.worksheets.select {|a| a if a.sheet_name == sheet_name }.first
      resources.each_with_index do |row, index|
        @keys = define_keys(row, index) if index.zero?
        next if index.zero? || row&.cells&.first.nil? || row&.cells&.first&.value.nil?

        yield(formatted_params(row))
      end
    end

    def load_excel(file_name)
      @excel = RubyXL::Parser.parse "lib/data/#{file_name}"
    end

    def load_data
      @excel.worksheets.each do |sheet|
        sheet_name = sheet.sheet_name
        reset(sheet_name)
        iterate_sheet_rows(sheet_name, sheet)
        reset_pk_sequence(sheet_name)
      end
    end

    def iterate_sheet_rows(sheet_name, sheet)
      print "Seeding #{sheet_name.downcase.pluralize}..."
      sheet.each_with_index do |row, index|
        @keys = define_keys(row, index) if index.zero?
        create_resource(sheet_name, formatted_params(row)) unless empty_row?(index, row)
      rescue StandardError => e
        puts e
      end
      puts ' done'
    end

    def client_logo(brand, brand_params)
      return if brand_params[:logo].blank?

      attach_image(brand_params[:logo], brand, 'logo')
    end

    def client_show_images(brand, brand_params)
      return if brand_params[:products_images].blank? || !brand_params[:products_images].first.is_a?(Hash)

      brand_params[:products_images].each_with_index do |data,  index|
        product = Product.find(data[:product_id])
        image = Attached::ResourceFile.find_by(owner: product, order: data[:orden])&.image
        create_resourse_file(image, brand, 'brand_show', index) if image.present?
      end
    end

    def define_keys(row, index)
      row&.cells&.map {|c| c&.value&.delete(' ')&.to_sym if c }.compact if index.zero?
    end

    def attach_image(image_name, owner, kind, index = 0)
      stored_file = storage_bucket.file("images/#{image_name}")
      if stored_file.present?
        image = create_or_find_image(stored_file)
        create_resourse_file(image, owner, kind, index)
      else
        puts "image #{image_name} not found"
      end
    end

    def attach_document(document_name, owner)
      stored_file = storage_bucket.file("documents/#{document_name}")
      if stored_file.present?
        document = Attached::Document.create!(name: File.basename(stored_file.name), url: stored_file.public_url )
        Attached::ResourceFile.create!(owner: owner, attached: document, kind: 'product_document')
      else
        puts "document #{document_name} not found"
      end
    end

    def create_resourse_file(image, owner, kind, index)
      Attached::ResourceFile.create!(owner: owner, attached: image, order: index, kind: kind)
    end

    def create_or_find_image(stored_file)
      filename = File.basename(stored_file.name)
      previous_image = Attached::Image.find_by(name: filename)
      return previous_image if previous_image.present?

      Attached::Image.create!(name: File.basename(stored_file.name), url: stored_file.public_url )
    end

    def create_resource(sheet_name, params)
      class_name = class_name(sheet_name)
      case sheet_name
      when 'client' then create_company(params)
      when 'product' then create_product(class_name, params)
      when 'item' then create_item(class_name, params)
      else default_create(class_name, params)
      end
    end

    def create_item(class_name, params)
      class_name.create!(params.except(:images))
    end

    def create_product(class_name, params)
      tags = params[:tags]&.split(",")&.map{|a| a.first.eql?(' ') ? a.gsub(' ', '') : a }
      class_name.create!(params.except(:images, :files).merge(tags: tags))
    end

    def create_company(params)
      creation_params = params.except(:distribuitors, :logo, :products_images, :type)
      if params[:type] == 'Client'
        Company::Client.create!(creation_params)
      elsif params[:type] == 'Brand'
        Company::Brand.create!(creation_params)
      end
    end

    def default_create(class_name, params)
      class_name.create!(params)
    end

    def database_connection
      Section.connection
      Item.connection
      Subitem.connection
      Company::Common.connection
    end

    def reset_images_and_files
      Attached::ResourceFile.delete_all
      Attached::File.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('attached_files')
      ActiveRecord::Base.connection.reset_pk_sequence!('attached_resource_files')
    end

    def reset_tables
      ProjectSpec::Text.delete_all
      ProjectSpec::Block.delete_all
    end

    def class_name(name)
      case name
      when 'client'
        Company::Common
      else
        name.camelize.constantize
      end
    end

    def empty_row?(index, row)
      index.zero? || row&.cells&.first.nil? || row&.cells&.first&.value.nil?
    end

    def formatted_params(row)
      values = row&.cells&.map {|a| a&.value }.map {|item| array_param(item) }
      @keys.zip(values).to_h
    end

    def array_param(param)
      case true
      when array_only?(param) then removed_parenthesis_array(param).map(&:to_i)
      when array_with_hashes?(param)
        array = removed_parenthesis_array(param).map {|string| hash_converter(string) }
        recursive_array_shift(array)
      when hash_only?(param) then hash_converter(param)
      else param
      end
    end

    def recursive_array_shift(array)
      @array ||= []
      if array.count == 0
        new_array = @array
        @array = []
        return new_array
      else
        data = array.shift(2)
        @array << data[0].merge(data[1])
        recursive_array_shift(array)
      end
    end

    def hash_converter(string)
      value = removed_parenthesis_array(string)
      Hash[
        value.collect do |i|
          [
            i.split(':').first.to_sym,
            convert_to_integer_or_string(i.split(':').second + (i.split(':').third || ''))
          ]
        end
      ]
    end

    def convert_to_integer_or_string(string)
      is_number?(string) ? string.to_i : string.gsub('https//', 'https://')
    end

    def is_number? string
      true if Float(string) rescue false
    end

    def array_only? param
      param.try(:include?, '[') && !param.try(:include?, '{')
    end

    def array_with_hashes? param
      param.try(:include?, '[') && param.try(:include?, '{')
    end

    def hash_only? param
      !param.try(:include?, '[') && param.try(:include?, '{')
    end

    def removed_parenthesis_array(param)
      param.gsub(/["#{Regexp.escape('[]{} ')}"]/, '').split(',')
    end

    def storage_bucket
      @storage_bucket ||= begin
        File.open('config/google_storage_config.json', 'w') {|f| f.write(ENV['GOOGLE_APPLICATION_CREDENTIALS']) }
        storage = Google::Cloud::Storage.new(
          project_id:  'spec-atelier',
          credentials: 'config/google_storage_config.json'
        )
        storage.bucket(ENV['GOOGLE_BUCKET_IMAGES'])
      end
    end

    def google_drive_session
      @google_drive_session ||= begin
        File.open('config/google_drive_config.json', 'w') {|f| f.write(ENV['GOOGLE_DRIVE_CONFIG']) }
        GoogleDrive::Session.from_config('config/google_drive_config.json')
      end
    end

    def download_excel_from_google_drive
      file = google_drive_session.file_by_title('bd.xlsx')
      file.download_to_file("lib/data/bd.xlsx")
      load_excel('bd.xlsx')
    end

    def reset(table_name)
      database_connection
      class_name(table_name).delete_all
    end

    def reset_pk_sequence(table_name)
      table_name = table_name == 'client' ? 'company' : table_name
      ActiveRecord::Base.connection.reset_pk_sequence!(table_name.pluralize, 'id')
    end
  end
end