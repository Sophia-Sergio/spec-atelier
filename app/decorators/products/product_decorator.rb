module Products
  class ProductDecorator < ApplicationDecorator
    delegate :id, :short_desc, :long_desc, :reference, :price, :original_product_id, :name, :unit
    new_keys :name,
             :system,
             :systems,
             :section,
             :sections,
             :item,
             :items,
             :brand,
             :client,
             :dwg,
             :bim,
             :pdfs,
             :images,
             :project_type,
             :room_type,
             :work_type,
             :user_owned

    def brand
      resource = model.brand
      { id: resource&.id, name: resource&.name }
    end

    def client
      resource = model.client
      { id: resource&.id, name: resource&.name }
    end

    def systems
      model.subitems.map {|subitem| { id: subitem&.id, name: subitem&.name } }
    end

    def sections
      model.sections.map {|section| { id: section&.id, name: section&.name } }
    end

    def item
      { id: item_object.id, name: item_object.name } if item_object.present?
    end

    def items
      model.items.map do |item|
        { id: item&.id, name: item&.name, section_id: item&.section_id }
      end
    end

    def dwg
      dwg_document = documents.with_dwg.first
      return {} unless dwg_document.present?

      { id: dwg_document.id, name: dwg_document.name, url: dwg_document.url }
    end

    def bim
      bim_document = documents.with_bim.first
      return {} unless documents.with_bim.present?

      { id: bim_document.id, name: bim_document.name, url: bim_document.url }
    end

    def pdfs
      pdf_documents = documents.with_pdf
      return [] unless pdf_documents.present?

      pdf_documents.map {|a| { id: a.id, name: a.name, url: a.url } }
    end

    def images
      product_images = model.images
      return [item_image] unless product_images.present?

      product_images.map {|a| { id: a.id, urls: a.all_formats, order: a.resource_file.order } }
    end

    def user_owned
      user == model.user
    end

    %w[project work room].each do |column|
      define_method("#{column}_type") { model.respond_to?("#{column}_type_key_value") ? model.send("#{column}_type_key_value") : []}
    end

    private

    def user
      @user ||= context[:user].presence
    end

    def documents
      @documents ||= model.documents
    end

    def item_image
      item = model.items.first
      { id: 1, hide_delete: true, urls: { small: item.image_url || '', medium: item.image_url || '' }, order: 0 }
    end
  end
end
