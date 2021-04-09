module BlocksOrder
  extend ActiveSupport::Concern

  included do
    before_create :set_item, if: -> { spec_item.instance_of? Product }
    before_create :set_section, if: -> { spec_item.instance_of? Item }
    before_create :update_order, if: -> { spec_item.instance_of? Product }
    after_create :reorder_blocks, if: -> { spec_item.instance_of? Product }
  end

  def reorder_blocks
    reorder_sections
    reorder_items
    reorder_products
    high_order_blocks.each_with_index do |block, index|
      block.update(order: index)
    end
  end

  def sections
    spec_blocks&.where(spec_item_type: 'Section')
  end

  def items(section_id)
    spec_blocks&.where(spec_item_type: 'Item', section_id: section_id)
  end

  def products(section_id, item_id)
    spec_blocks.where(spec_item_type: 'Product', section_id: section_id, item_id: item_id)
  end

  def block_section_order
    sections.find_by(section_id: section_id).section_order
  end

  def block_item_order(section_id)
    items(section_id).find_by(item_id: item_id).item_order
  end

  def reorder_sections
    Section.where(id: sections.pluck(:spec_item_id)).order(:show_order).each.with_index do |section, i|
      sections.find_by(spec_item: section)
              .update(section_order: i + 1, item_order: 0, product_order: 0)
    end
  end

  def reorder_items
    sections.each do |section|
      items = items(section.section_id)
      Item.where(id: items.pluck(:spec_item_id)).order(:show_order).each.with_index do |item, i|
        spec_item = items.find_by(spec_item: item)
        spec_item.update(section_order: spec_item.block_section_order, item_order: i + 1, product_order: 0)
      end
    end
  end

  def reorder_products
    sections.each do |section|
      items(section.section_id).each do |item|
        products(section.section_id, item.item_id).order(:product_order).each_with_index do |product, index|
          product.update(
            section_order: product.block_section_order,
            item_order:    product.block_item_order(product.section_id),
            product_order: index + 1
          )
        end
      end
    end
  end

  private

  def update_order
    self.product_order = next_product_order
  end

  def set_section
    section = spec_item.section
    return if section_names.include?(section.name)

    spec_blocks.create!(spec_item: section, section: section)
  end

  def set_item
    item = Item.find(item_id)
    return if item_names.include?(item.name)

    spec_blocks.create!(spec_item: item, section: item.section, item: item)
  end

  def spec_blocks
    project_spec.blocks
  end

  def high_order_blocks
    spec_blocks.order(:section_order, :item_order, :product_order)
  end

  def current_max_order
    spec_blocks&.pluck(:order)&.max
  end

  def next_product_order
    (spec_blocks
      &.where(spec_item_type: 'Product', item_id: item_id)
      &.count || 0 ) + 1
  end

  def item_names
    spec_blocks.includes(:spec_item).where(spec_item_type: 'Item').map {|b| b.spec_item.name }
  end

  def section_names
    spec_blocks.includes(:spec_item).where(spec_item_type: 'Section').map {|b| b.spec_item.name }
  end

end
