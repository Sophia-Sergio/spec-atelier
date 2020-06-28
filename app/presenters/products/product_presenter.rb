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
               :dwg,
               :bim,
               :pdfs,
               :images

    def brand
      resource = product.brand
      { id: resource.id, name: resource.name }
    end

    def system
      resource = product.subitem
      { id: resource&.id, name: resource&.name }
    end

    def section
      { id: product.section.id, name: product.section.name }
    end

    def item
      { id: product.item.id, name: product.item.name }
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

      pdf_documents.positioned.map {|a| { name: a.name, url: a.url } }
    end

    def images
      product_images = product.images
      return [] unless product_images.present?

      product_images.positioned.map {|a| { urls: a.all_formats, order: a.order } }
    end

    private

    def documents
      @documents ||= product.documents
    end
  end
end
