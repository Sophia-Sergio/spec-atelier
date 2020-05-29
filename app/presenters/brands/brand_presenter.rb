module Brands
  class BrandPresenter < Presenter
    will_print :id, :name, :products_count, :description, :address, :country, :phone, :web, :email, :social_media

    def products_count
      brand.products.count
    end
  end
end
