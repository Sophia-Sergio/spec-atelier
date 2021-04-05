module Products
  class ProductSpecCreator < Products::ProductCommon

    def call
      Product.transaction do
        new_product = product.dup
        new_product.update!(creation_params)
        product.files.each {|file| file.dup.update(owner: new_product) }
        product.product_items.each {|item| item.dup.update(product: new_product) }
        product.product_subitems.each {|subitem| subitem.dup.update(product: new_product) }
        new_product
      end
    end

    private

    def creation_params
      product_params.merge(
        original_product_id: product.id,
        created_reason: :added_to_spec,
        spec_item_id: params[:item].to_i
      )
    end
  end
end
