module ProjectSpec
  class Specification < ApplicationRecord
    self.table_name = :project_specs

    belongs_to :project
    has_one :user, through: :project
    has_many :blocks, class_name: 'ProjectSpec::Block', foreign_key: :project_spec_id
    scope :by_product, lambda {|products|
      product_ids = Product.where(original_product_id: products).pluck(:id)
      with_products.where(project_spec_blocks: { spec_item_id: product_ids, spec_item_type: 'Product' })
    }
    scope :by_user, ->(user) { joins(:user).where(users: { id: user }) }
    scope :with_products, -> { joins(:blocks).distinct }

    delegate :products, to: :blocksç
    delegate :name, to: :project

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


    def remove_product(block)
      self.class.transaction do
        text = ProjectSpec::Text.find_by(block_item: block)
        blocks.unscoped.find_by(spec_item: text)&.destroy
        text&.destroy
        blocks.find_by(spec_item: block.item)&.destroy if blocks.products.where(item: block.item).count == 1
        blocks.find_by(spec_item: block.section)&.destroy if blocks.products.where(section: block.section).count == 1
        block.spec_item.destroy
        blocks.find(block.id).destroy
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
