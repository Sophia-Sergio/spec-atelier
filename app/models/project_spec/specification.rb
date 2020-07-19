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

    def create_product(params)
      product = Product.find(params[:product])
      blocks.create!(spec_item: product, section_id: params[:section], item_id: params[:item])
      product
    end

    def remove_product(block_id)
      block = blocks.find(block_id)
      item = block.item
      blocks.find_by(spec_item: item).delete if blocks.where(spec_item_type: 'Product', item: block.item).count == 1
      blocks.find(block_id).delete
    end

    def create_default_first_section
      blocks.create!(spec_item: Section.find_by(name: 'Terminación'))
    end
  end
end
