module BlocksOrder
  extend ActiveSupport::Concern

  included do
    before_create :set_item, if: -> { spec_item.class == Product }
    before_create :set_section, if: -> { spec_item.class == Item }
    before_create :set_order, if: -> { spec_item.class != ProjectSpec::Text }
    after_create :reorder_blocks, if: -> { spec_item.class == Product }
    after_destroy :reorder_blocks, if: -> { spec_item.class == Product }
  end



  def reorder_blocks
    high_order_blocks.each_with_index do |block, index|
      block.update(order: order + index + 1)
    end
  end

  private

  def set_order
    self.order = next_order
    case spec_item_type
    when 'Product'
      self.product_order = next_product_order
      self.item_order = current_item_order
      self.section_order = current_section_order
    when 'Item'
      self.item_order = next_item_order
      self.section_order = current_section_order
    when 'Section'
      self.section_order = next_section_order
    end
  end

  def set_section
    section = spec_item.section
    return if section_names.include?(section.name)

    spec_blocks.create!(spec_item: section, section: section)
  end

  def set_item
    product = spec_item
    item = product.spec_item
    return if item_names.include?(item.name)

    spec_blocks.create!(spec_item: item, section: item.section, item: item)
  end

  def spec_blocks
    project_spec.blocks
  end

  def high_order_blocks
    spec_blocks.where('project_spec_blocks.order >= ? and id <> ?', order, id)
  end

  def high_order_product_blocks
    spec_blocks.where('project_spec_blocks.spec_item_type = ? and item_id = ? ', 'Product', item_id).order(:order)
  end

  def current_max_order
    spec_blocks&.pluck(:order)&.max
  end

  def current_max_order_by_item
    spec_blocks&.where(item: spec_item.spec_item)&.pluck(:order)&.max
  end
  
  def current_max_order_by_section
    spec_blocks&.where(section: spec_item.section)&.pluck(:order)&.max
  end

  def next_order
    if spec_item_type == 'Product'
      current_max_order_by_item.present? ? current_max_order_by_item + 1 : current_max_order + 1
    elsif spec_item_type == 'Item'
      current_max_order_by_section.present? ? current_max_order_by_section + 1 : 0
    else
      current_max_order.present? ? current_max_order + 1 : 0
    end
  end

  def next_product_order
    (spec_blocks&.where(spec_item_type: 'Product', item_id: item_id)&.pluck(:product_order)&.compact&.max || 0 ) + 1
  end

  def next_item_order
    (spec_blocks&.where(spec_item_type: 'Item', section_id: section_id)&.pluck(:item_order)&.compact&.max || 0 ) + 1
  end

  def next_section_order
    (spec_blocks&.where(spec_item_type: 'Section')&.pluck(:section_order)&.compact&.max || 0 ) + 1
  end

  def current_item_order
    (spec_blocks&.where(spec_item_type: 'Item', spec_item_id: self.item_id)&.pluck(:item_order)&.compact&.max || 0 )
  end

  def current_section_order
    (spec_blocks&.where(spec_item_type: 'Section', spec_item_id: self.section_id)&.pluck(:section_order)&.compact&.max || 0 )
  end

  def item_names
    spec_blocks.includes(:spec_item).where(spec_item_type: 'Item').map {|b| b.spec_item.name }
  end

  def section_names
    spec_blocks.includes(:spec_item).where(spec_item_type: 'Section').map {|b| b.spec_item.name }
  end

end
