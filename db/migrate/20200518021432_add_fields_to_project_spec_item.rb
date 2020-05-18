class AddFieldsToProjectSpecItem < ActiveRecord::Migration[6.0]
  def change
    add_reference :project_spec_items, :section, null: false, foreign_key: true
    add_reference :project_spec_items, :item, null: false, foreign_key: true
  end
end
