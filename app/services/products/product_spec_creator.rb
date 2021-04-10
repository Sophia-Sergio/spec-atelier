module Products
  class ProductSpecCreator < Products::ProductCommon
    extend CallableCommand
    attr_reader :project_spec

    def initialize(params, user, product, project_spec:)
      super(params, user, product)
      @project_spec = project_spec
    end

    def call
      Product.transaction do
        new_product = product.dup
        new_product.update!(creation_params)
        product.files.each {|file| file.dup.update(owner: new_product) }
        product.product_items.each {|item| item.dup.update(product: new_product) }
        product.product_subitems.each {|subitem| subitem.dup.update(product: new_product) }
        create_spec_item_product(new_product)
      end
    end

    private

    def creation_params
      product_params.merge(
        original_product_id: product.id,
        created_reason: :added_to_spec
      )
    end

    def create_spec_item_product(new_product)
      items = params[:item].is_a?(Array) ? params[:item] : [params[:item]]
      items.each do |item_id|
        item = Item.find(item_id)
        project_spec.blocks.create(
          spec_item: new_product,
          section_id: item.section_id,
          item_id: item.id
        )
      end
    end
  end
end
