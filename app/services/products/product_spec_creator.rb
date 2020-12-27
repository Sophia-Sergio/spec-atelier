module Products
  class ProductSpecCreator < Products::ProductCommon

    def call
      Product.create(creation_params)
    end

    def creation_params
      product_params.merge({ original_product_id: product.id, created_reason: 1, spec_item_id: params[:item].to_i })
    end
  end
end
