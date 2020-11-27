module ProjectSpec
  class Block < ApplicationRecord
    include BlocksOrder

    def self.table_name_prefix
      'project_spec_'
    end

    belongs_to :project_spec, class_name: 'ProjectSpec::Specification'
    belongs_to :spec_item, polymorphic: true
    belongs_to :section, optional: true
    belongs_to :item, optional: true
    scope :products, -> { where(spec_item_type: 'Product') }

    after_destroy :cleanup

    validates :section_id, presence: true, if: -> { spec_item.instance_of?(Item) || spec_item.instance_of?(Product)}

    default_scope { where.not(spec_item_type: 'ProjectSpec::Text') }

    def text
      ProjectSpec::Text.find_by(block_item: self)
    end

    def product_image
      Attached::Image.find(product_image_id) if product_image_id.present?
    end

    def product_item_block
      spec_blocks.find_by(spec_item_type: 'Item', spec_item_id: item_id) if spec_item.class == Product
    end

    def cleanup
      binding.pry
      item.destroy if ['Product', 'ProjectSpec::Text'].include? spec_item_type
    end
  end
end
