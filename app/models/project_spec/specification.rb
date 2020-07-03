module ProjectSpec
  class Specification < ApplicationRecord
    self.table_name = :project_specs

    belongs_to :project
    has_one :user, through: :project
    has_many :specification_items, class_name: 'ProjectSpec::Item', foreign_key: :project_spec_id


    def create_text(text, item_id, section_id)
      text = ProjectSpec::Text.create(text: text)
      ProjectSpec::Item.create!(
        spec_item_type: 'ProjectSpec::Text',
        spec_item_id: text.id,
        user: user,
        item_id: 1,
        section_id: section_id,
        project_spec: self
      )
      text
    end
  end
end
