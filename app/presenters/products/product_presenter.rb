module Products
  class ProductPresenter < Presenter
    will_print :id,
               :name,
               :short_desc,
               :long_desc,
               :system,
               :section,
               :item,
               :reference,
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
      resource = subject.brand
      { id: resource.id, name: resource.name }
    end

    def client
      resource = subject.client
      { id: resource.id, name: resource.name }
    end

    def system
      resource = subject.subitem
      { id: resource&.id, name: resource&.name }
    end

    def section
      { id: subject.section.id, name: subject.section.name }
    end

    def item
      { id: subject.item.id, name: subject.item.name }
    end

    def dwg
      dwg_document = documents.with_dwg.first
      return {} unless dwg_document.present?

      { name: dwg_document.name, url: dwg_document.url }
    end

    def bim
      bim_document = documents.with_bim.first
      return {} unless documents.with_bim.present?

      { name: bim_document.name, url: bim_document.url }
    end

    def pdfs
      pdf_documents = documents.with_pdf
      return [] unless pdf_documents.present?

      pdf_documents.map {|a| { name: a.name, url: a.url } }
    end

    def images
      product_images = subject.images
      return [item_image] unless product_images.present?

      product_images.map {|a| { id: a.id, urls: a.all_formats, order: a.resource_file.order } }
    end

    %w[project work room].each do |column|
      define_method("#{column}_type") { subject.send("#{column}_type_key_value") || []}
    end

    private

    def documents
      @documents ||= subject.documents
    end

    def item_image
      { id: 1, urls: { small: subject.item&.image_url || ''}, order: 0 }
    end
  end
end
