module ProjectSpec
  class Specification < ApplicationRecord
    self.table_name = :project_specs

    belongs_to :project
    has_one :user, through: :project
    has_many :blocks, class_name: 'ProjectSpec::Block', foreign_key: :project_spec_id

    scope :with_products, -> { joins(:blocks).distinct }

    def create_text(params)
      text = ProjectSpec::Text.create!(text: params[:text], project_spec_block_id: params[:block])
      blocks.create!(spec_item: text)
      text
    end

    def remove_text(text_id)
      text = ProjectSpec::Text.find(text_id).delete
      blocks.unscoped.find_by(spec_item: text).delete
    end

    def remove_block(block_id)
      block = blocks.find(block_id)
      send("remove_#{block.spec_item_type.downcase}", block)
      block.send(:reorder_blocks)
    end

    def reorder_blocks(block_params)
      block_params.each_with_index do |block_param, index|
        block = blocks.find(block_param[:block])
        block_orders(block, index)
      end
    end

    private

    def block_orders(block, index)
      @current_item ||= nil
      @product_order ||= 0
      @item_order ||= 0
      @section_order ||= 0

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

    def remove_product(block)
      self.class.transaction do
        text = ProjectSpec::Text.find_by(block_item: block)
        blocks.unscoped.find_by(spec_item: text)&.delete
        text&.delete
        blocks.find_by(spec_item: block.item)&.delete if blocks.products.where(item: block.item).count == 1
        blocks.find_by(spec_item: block.section)&.delete if blocks.products.where(section: block.section).count == 1
        blocks.find(block.id).delete
      end
    end

    def remove_section(block)
      blocks.unscoped.where(section: block.section).delete_all
    end

    def remove_item(block)
      blocks.find_by(spec_item: block.section)&.delete if blocks.products.where(section: block.section).count == 1
      blocks.unscoped.where(item: block.item).delete_all
    end
  end
end
