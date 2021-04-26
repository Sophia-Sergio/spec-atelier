module Products
  class ProductSpecDecorator < ApplicationDecorator
    delegate :id, :short_desc, :long_desc, :reference
    new_keys :name,
             :brand,
             :images,
             :user_owned

    def name
      "#{block.section_order}.#{block.item_order}.#{block.product_order}. #{model.name}"
    end

    def brand
      resource = model.brand
      { id: resource&.id, name: resource&.name }
    end

    def images
      product_images = model.images
      return [item_image] unless product_images.present?

      product_images.map {|a| { id: a.id, urls: a.all_formats, order: a.resource_file.order } }
    end

    def user_owned
      model.original_product.user == model.user
    end

    private

    def block
      @block ||= context[:block].presence
    end
  end
end
