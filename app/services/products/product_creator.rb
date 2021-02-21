module Products
  class ProductCreator < Products::ProductCommon

    def call
      product = ::Product.new(product_params)
      brand = Brand.find_or_initialize_by(name: params[:brand])
      brand.save! if brand.new_record?
      product.brand = brand if brand.valid?
      product.save!
      items_creation(product, params[:item])
      subitems_creation(product, params[:system]) if params[:system].present?
      product
    end

    private

    def items_creation(product, items)
      items.each {|item_id| ProductItem.create!(product_id: product.id, item_id: item_id) }
    end

    def subitems_creation(product, subitems)
      subitems.each do |subitem|
        ProductSubitem.create!(product: product, subitem_id: subitem) if subitem_belongs_to_known_item? subitem
      end
    end
  end
end
