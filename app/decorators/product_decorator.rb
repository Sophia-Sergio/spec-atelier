class ProductDecorator < ApplicationDecorator
  delegate :id, :name, :short_desc, :long_desc, :reference

  new_keys :system,
          :section,
          :item,
          :brand,
          :client,
          :dwg,
          :bim,
          :pdfs,
          :images,
          :project_type,
          :room_type,
          :work_type

  def brand
    resource = model.brand
    { id: resource&.id, name: resource&.name }
  end

  def client
    resource = model.client
    { id: resource&.id, name: resource&.name }
  end

  def system
    resource = model.subitem
    { id: resource&.id, name: resource&.name }
  end

  def section
    { id: model.section.id, name: model.section.name }
  end

  def item
    { id: model.item.id, name: model.item.name }
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

  %w[project work room].each do |column|
    define_method("#{column}_type") { model.respond_to?("#{column}_type_key_value") ? model.send("#{column}_type_key_value") : []}
  end

  private

  def documents
    @documents ||= model.documents
  end

  def item_image
    { id: 1, urls: { small: model.item&.image_url || ''}, order: 0 }
  end
end
