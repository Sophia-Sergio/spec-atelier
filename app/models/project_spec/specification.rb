module ProjectSpec
  class Specification < ApplicationRecord
    self.table_name = :project_specs

    belongs_to :project
    has_one :user, through: :project
    has_many :blocks, class_name: 'ProjectSpec::Block', foreign_key: :project_spec_id

    after_create :create_default_first_section # this is for the first mvp, when more section be available, this should be removed

    def create_text(params)
      text = ProjectSpec::Text.create!(text: params[:text], project_spec_block_id: params[:block])
      blocks.create!(spec_item: text)
      text
    end

    def remove_text(text_id)
      text = ProjectSpec::Text.find(text_id).delete
      blocks.unscoped.find_by(spec_item: text).delete
    end

    def create_product(params, user)
      original_product =  Product.find(params[:product])
      original_product_params = original_product.as_json.except('id')
      product = Product.create(original_product_params.merge({
        original_product_id: original_product.id,
        created_reason: 1,
        user: user
      }))
      original_product.files.each {|file| file.dup.update(owner: product) }
      blocks.create!(spec_item: product, section_id: params[:section], item_id: params[:item])
      product
    end

    def remove_product(block_id)
      block = blocks.find(block_id)
      item = block.item
      blocks.find_by(spec_item: item)&.delete if blocks.where(spec_item_type: 'Product', item: block.item).count == 1
      blocks.find(block_id).delete
    end

    def create_default_first_section
      blocks.create!(spec_item: Section.find_by(name: 'Terminación'))
    end

    def reorder_blocks(block_params)
      block_params.each_with_index do |block_param, index|
        block = blocks.find(block_param[:block])
        updated_orders = block_orders(block, index)
      end
    end

    private

    def block_orders(block, index)
      @current_item ||= nil
      @product_order ||= 0
      @item_order ||= 0
      @section_order ||= 0;

      if block.spec_item_type == 'Item' && @current_item != block.spec_item.name
        item_update(block, index)
      elsif block.spec_item_type == 'Product'
        product_update(block, index)
      elsif block.spec_item_type == 'Section'
        section_update(block, index)
      end
    end

    def item_update(block, index)
      @current_item = block.spec_item.name
      @item_order += 1
      @product_order = 0
      block.update(item_order: @item_order, order: index, section_order: @section_order)
    end

    def product_update(block, index)
      @product_order += 1
      block.update(item_order: @item_order, order: index, section_order: @section_order, product_order: @product_order)
    end

    def section_update(block, index)
      @section_order += 1
      block.update(order: index, section_order: @section_order)
    end
  end
end
