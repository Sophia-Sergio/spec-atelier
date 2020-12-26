module Products
  class ProductUpdater < Products::ProductCommon

    def call
      Product.transaction do
        product.update(product_params)
        items_update(product, params[:item]) if params[:item].present?
        subitems_update(product, params[:system]) if params[:system].present?
        product
      end
    end

    private

    def items_update(product, items)
      product.product_items.where.not(item_id: items).delete_all
      items.each {|item| ProductItem.find_or_create_by!(product: product, item_id: item) }
    end

    def subitems_update(product, subitems)
      product.product_subitems.where.not(subitem_id: subitems).delete_all
      subitems.each do |subitem|
        if subitem_belongs_to_known_item? subitem
          ProductSubitem.find_or_create_by!(product: product, subitem_id: subitem)
        end
      end
    end
  end
end
