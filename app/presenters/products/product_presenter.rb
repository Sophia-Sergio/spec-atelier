module Products
  class ProductPresenter < Presenter
    will_print :id,
               :name,
               :short_desc,
               :long_desc,
               :system,
               :reference,
               :brand,
               :dwg_url,
               :bim_url,
               :spec_pdf_url,
               :images

    def brand
      resource = product.brand
      { name: resource.name, id: resource.id }
    end

    def system
      resource = product.subitem
      { name: resource&.name, id: resource&.id }
    end

    def dwg_url
      ''
    end

    def bim_url
      ''
    end

    def spec_pdf_url
      ['', '']
    end

    def images
      return [] unless product.images.present?

      product.images.positioned.order(:order).map do |a|
        { urls: a.all_formats, order: a.order }
      end
    end
  end
end
