module Products
  class ProductCreator < Products::ProductCommon

    def call
      ::Product.transaction do
        product = ::Product.create(product_params)
        brand = Brand.find_or_create_by(name: params[:brand])
        product.brand = brand if brand.valid?
        items_creation(product, params[:item_id])
        subitems_creation(product, params[:system_id]) if params[:system_id].present?
        product
      end
    end

    private

    def items_creation(product, items)
      items.each {|item| ProductItem.create!(product: product, item_id: item) }
    end

    def subitems_creation(product, subitems)
      subitems.each do |subitem|
        ProductSubitem.create!(product: product, subitem_id: subitem) if subitem_belongs_to_known_item? subitem
      end
    end
  end
end
