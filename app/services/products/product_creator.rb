module Products
  class ProductCreator < Products::ProductCommon

    def call
      product = ::Product.create(product_params)
      brand = Brand.find_or_create_by(name: product_params[:brand])
      product.brand = brand if brand.valid?
      Product.transaction do 
        ProductItem.create(product: product, item_id: params[:item_id])
        ProductSubitem.create(product: product, subitem_id: params[:system_id])
      end
      product
    rescue
      brand.delete if brand.new_record?
      product.delete
    end
  end
end