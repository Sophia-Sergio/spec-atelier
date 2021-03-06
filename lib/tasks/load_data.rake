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
    end

    task tables: :environment do
      download_excel_from_google_drive('bd.xlsx', all: true)
      reset_tables
      load_data
    end

    task :new_products, [:date] => :environment do |_, arg|
      path = ['specatelier', 'uploads', arg[:date], 'new_products']
      download_excel_from_google_drive(path)
      load_new_products
    end

    task :new_clients, [:date] => :environment do |_, arg|
      path = ['specatelier', 'uploads', arg[:date], 'new_clients']
      download_excel_from_google_drive(path)
      load_new_clients
    end

    task images_and_documents: :environment do
      download_excel_from_google_drive('bd.xlsx', all: true)
      reset_images_and_files
      process_item_image
      print "Seeding product images..."
      select_sheet('product') {|params| process_product_images(params) }
      print "Seeding product documents..."
      select_sheet('product') {|params| process_product_documents(params) }
      process_client_images
      sh 'rm config/google_storage_config.json'
      sh 'rm config/google_drive_config.json'
    end

    tasks = Rake.application.tasks.select do |task|
      task if ['db:load:tables', 'db:load:images_and_documents', 'db:load:new_products'].include?(task.to_s)
    end
    tasks.each {|task| task.enhance [:before_hook] }

    private

    def load_new_products
      select_sheet('product') do |params|
        if Product.find_by(find_except_product_params(params)).present?
          puts "<Product id: #{params[:id].to_i}, name: #{params[:name]}> already exists, it will be skiped"
          next
        end
        Product.transaction do
          create_product(params)
          process_product_images(params)
          process_product_documents(params)
        end
      end
    end

    def load_new_clients
      select_sheet('client') do |params|
        if Client.find_by(find_except_client_params(params)).present?
          puts "<Client id: #{params[:id].to_i}, name: #{params[:name]}> already exists, it will be skiped"
          next
        end
        create_client(params)
      end
      select_sheet('address') do |params|
        next unless Client.find_by(name: params[:owner]).present?

        if Address.find_by(find_except_address_params(params)).present?
          puts "<Address id: #{params[:id].to_i}, text: #{params[:text]}> already exists, it will be skiped"
          next
        end
        create_address(params)
      end

      select_sheet('brand') do |params|
        next unless Client.find_by(name: params[:client]).present?

        if Brand.find_by(find_except_brand_params(params)).present?
          puts "<Brand id: #{params[:id].to_i}, name: #{params[:name]}> already exists, it will be skiped"
          next
        end
        create_brand(params)
      end
    end

    def process_product_documents(params)
      return if params[:files].blank?

      documents = params[:files].split(',').map {|a| a.gsub('/', '_').strip }
      products = Product.where(find_except_product_params(params))
      products.each do |product|
        documents.each {|document| attach_document(document, product) }
      end
    rescue StandardError => e
      puts e
    end

    def find_except_product_params(params)
      client_and_brand = {
        tags: tags(params[:tags]),
        brand_id: Brand.find_by(name: params[:brand]).id,
        client_id: Client.find_by(name: params[:client]).id
      }
      params.except(:images, :files, :subitem_id, :room_type, :id, :tags, :brand, :client).merge(client_and_brand)
    end

    def find_except_client_params(params)
      params.except(:id, :distribuitors, :logo, :products_images)
    end

    def find_except_brand_params(params)
      client = { client_id: Client.find_by(name: params[:client]).id }
      params.except(:id, :client).merge(client)
    end

    def find_except_address_params(params)
      owner = { owner_id: Client.find_by(name: params[:owner]).id }
      params.except(:owner, :id).merge(owner)
    end

    def process_product_images(params)
      return if params[:images].blank?

      images = params[:images].split(',').map {|a| a.gsub('/', '_').strip }
      products = Product.where(find_except_product_params(params))
      products.each do |product|
        images.each_with_index {|image, index| attach_image(image, product, 'product_image', index) }
      end
    rescue StandardError => e
      puts e
    end

    def process_item_image
      print "Seeding item images..."
      select_sheet('item') do |item_params|
        next if item_params[:images].blank?

        images = item_params[:images].split(',').map {|a| a.gsub('/','_').strip }
        item = Item.find(item_params[:id])
        images.each_with_index {|image, index| attach_image(image, item, 'item_image', index) }
      rescue StandardError => e
        puts e
      end
      puts 'done'
    end

    def process_client_images
      print "Seeding client images..."
      select_sheet('client') do |client_params|
        company = Client.find(client_params[:id])
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
        reset_pk_sequence(sheet_name)
        iterate_sheet_rows(sheet_name, sheet)
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
      row&.cells&.map {|c| c&.value&.delete(' ')&.to_sym if c }&.compact if index.zero?
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
      when 'client' then create_client(params)
      when 'address' then create_address(params)
      when 'brand' then create_brand(params)
      when 'product' then create_product(params)
      when 'item' then create_item(class_name, params)
      else default_create(class_name, params)
      end
    end

    def create_item(class_name, params)
      params[:code] = format_code(params[:code]) if params[:code].present?
      class_name.create!(params.except(:images))
    end

    def create_product(params)
      product = Product.new(find_except_product_params(params))
      product.room_type = LookupTable.by_project_type(product.project_type).pluck(:code).map(&:to_s)
      product.save!
      subitem_id = params[:subitem_id].is_a?(Array) ? params[:subitem_id] : [params[:subitem_id]]
      subitem_id.each {|subitem| create_product_items_and_subitems(subitem, product) }
    end

    def tags(tags)
      tags&.split(",")&.map {|a| a.first.eql?(' ') ? a.gsub(' ', '') : a }
    end

    def create_product_items_and_subitems(subitem, product)
      ProductSubitem.create!(product: product, subitem_id: subitem)
      ProductItem.find_or_create_by(product: product, item: Subitem.find(subitem).item)
    end

    def create_address(params)
      Address.create!(find_except_address_params(params))
    end

    def create_client(params)
      Client.create!(find_except_client_params(params))
    end

    def create_brand(params)
      Brand.create!(find_except_brand_params(params))
    end

    def default_create(class_name, params)
      params[:code] = format_code(params[:code]) if params[:code].present?
      class_name.create!(params)
    end

    def format_code(code)
      code = code.to_s[/[^.]+/]
      code = "0#{code}" if code.length == 1 && number?(code) && code != '0'
      code
    end

    def database_connection
      Section.connection
      Item.connection
      Subitem.connection
    end

    def reset_images_and_files
      Attached::ResourceFile.delete_all
      Attached::File.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('attached_files')
      ActiveRecord::Base.connection.reset_pk_sequence!('attached_resource_files')
    end

    def reset_tables
      ProductItem.delete_all
      ProductSubitem.delete_all
      ProjectSpec::Text.delete_all
      ProjectSpec::Block.delete_all
    end

    def class_name(name)
      name.camelize.constantize
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
      if array.count.zero?
        new_array = @array
        @array = []
        new_array
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
      number?(string) ? string.to_i : string.gsub('https//', 'https://')
    end

    def number?(string)
      true if Float(string) rescue false
    end

    def array_only?(param)
      param.try(:include?, '[') && !param.try(:include?, '{')
    end

    def array_with_hashes?(param)
      param.try(:include?, '[') && param.try(:include?, '{')
    end

    def hash_only?(param)
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

    def download_excel_from_google_drive(name, all: false)
      file = google_drive_session.file_by_title(name)
      name = all ? name : "#{name.last}.xlsx"
      path = "lib/data/#{name}"
      all ? file.download_to_file(path) : file.export_as_file(path)
      load_excel(name)
    end

    def reset(table_name)
      database_connection
      class_name(table_name).delete_all
    end

    def reset_pk_sequence(table_name)
      ActiveRecord::Base.connection.reset_pk_sequence!(table_name.pluralize, 'id')
    end
  end
end
