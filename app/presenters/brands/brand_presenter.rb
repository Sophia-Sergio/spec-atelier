module Brands
  class BrandPresenter < Presenter
    will_print :id, :name, :products_count, :description, :address, :country, :phone, :web, :email, :social_media, :product_images, :contact_type

    def products_count
      brand.products.count
    end

    def description
      "<p><strong>Pellentesque habitant morbi tristique</strong> senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. <em>Aenean ultricies mi vitae est.</em> Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, <code>commodo vitae</code>, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui</p>"
    end

    def image
      "http://lorempixel.com/200/200"
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

    def phone
      '+56 9 9994 4656'
    end

    def contact_type
      'Call Center'
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
