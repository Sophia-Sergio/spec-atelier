module Brands
  class BrandPresenter < Presenter
    will_print :id, :name, :products_count, :description, :address, :country, :phone, :web, :email, :social_media

    def products_count
      brand.products.count
    end

    def image
      "http://lorempixel.com/200/200"
    end

    def description
      "lorem i"
    end

    def email
      'brand@brand.com'
    end

    def country
      'Chile'
    end

    def web
      'www.brand.com'
    end

    def address
      'Martín de Zamora 5315, oficina 22. Las Condes'
    end

    def social_media
      [
        { name: 'facebook', url: 'www.facebook.com/brand_name'},
        { name: 'twitter', url: 'www.twitter.com/brand_name'},
      ]
    end

    def product_images
      [
        { id: 1, url: "http://lorempixel.com/400/200" },
        { id: 2, url: "http://lorempixel.com/400/200" },
        { id: 3, url: "http://lorempixel.com/400/200" },
        { id: 4, url: "http://lorempixel.com/400/200" },
        { id: 5, url: "http://lorempixel.com/400/200" },
      ]
    end
  end
end
