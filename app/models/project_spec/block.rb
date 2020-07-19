module ProjectSpec
  class Block < ApplicationRecord
    def self.table_name_prefix
      'project_spec_'
    end

    belongs_to :project_spec, class_name: 'ProjectSpec::Specification'
    belongs_to :spec_item, polymorphic: true
    belongs_to :section, optional: true
    belongs_to :item, optional: true

    validates :section_id, presence: true, if: -> { spec_item.class == Item || spec_item.class == Product}

    before_create :set_item, if: -> { spec_item.class == Product }
    before_create :set_order, if: -> { spec_item.class != ProjectSpec::Text }
    after_create :reorder_blocks, if: -> { spec_item.class == Product }
    after_destroy :reorder_blocks, if: -> { spec_item.class == Product }

    default_scope { where.not(spec_item_type: 'ProjectSpec::Text') }

    def set_order
      self.order = next_order
    end

    def reorder_blocks
      high_order_blocks.each_with_index do |block, index|
        block.update(order: order + index + 1)
      end
    end

    def set_item
      item = spec_item.item
      return if item_names.include?(item.name)

      spec_blocks.create!(spec_item: item, section: item.section)
    end

    def text
      ProjectSpec::Text.find_by(block_item: self)
    end

    private

    def spec_blocks
      project_spec.blocks
    end

    def high_order_blocks
      spec_blocks.where('project_spec_blocks.order >= ? and id <> ?', order, id)
    end

    def current_max_order
      spec_blocks&.pluck(:order)&.max
    end

    def current_max_order_by_item
      spec_blocks&.where(item: spec_item.item)&.pluck(:order)&.max
    end

    def next_order
      if spec_item.class == Product
        current_max_order_by_item.present? ? current_max_order_by_item + 1 : current_max_order + 1
      else
        current_max_order.present? ? current_max_order + 1 : 0
      end
    end

    def item_names
      spec_blocks.includes(:spec_item).where(spec_item_type: 'Item').map {|b| b.spec_item.name }
    end
  end
end
