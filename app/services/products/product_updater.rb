module Products
  class ProductUpdater < Products::ProductCommon

    def call
      product.update(product_params.except(:system_id, :brand))
      Product.transaction do 
        ProductItem.find_or_create_by(product: product, item_id: params[:item_id])
        ProductSubitem.find_or_create_by(product: product, subitem_id: params[:system_id])
      end
      product
    end
  end
end