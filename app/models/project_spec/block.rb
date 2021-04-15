module ProjectSpec
  class Block < ApplicationRecord
    include BlocksOrder

    def self.table_name_prefix
      'project_spec_'
    end

    belongs_to :project_spec, class_name: 'ProjectSpec::Specification'
    belongs_to :spec_item, polymorphic: true
    belongs_to :product, -> {
      joins('INNER JOIN project_spec_blocks ON project_spec_blocks.spec_item_id = products.id')
        .where(project_spec_blocks: { spec_item_type: 'Product' })
    }, foreign_key: 'spec_item_id', optional: true
    belongs_to :section, optional: true
    belongs_to :item, optional: true
    has_one :text, class_name: 'ProjectSpec::Text', foreign_key: 'project_spec_block_id'
    scope :products, -> { where(spec_item_type: 'Product') }

    validates :section_id, presence: true, if: -> { spec_item.instance_of?(Item) || spec_item.instance_of?(Product)}

    default_scope { where.not(spec_item_type: 'ProjectSpec::Text') }


    def product_image
      Attached::Image.find(product_image_id) if product_image_id.present?
    end

    def product_item_block
      spec_blocks.find_by(spec_item_type: 'Item', spec_item_id: item_id) if spec_item.class == Product
    end

  end
end
