module ProjectSpec
  class BlocksUserReorder
    extend CallableCommand
    attr_reader :blocks, :block_params

    def initialize(project_spec, block_params)
      @blocks = project_spec.blocks
      @block_params = block_params
    end

    def call
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
      @item_order = 0
      block.update(order: index, section_order: @section_order)
    end
  end
end
