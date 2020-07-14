class RemoveFieldsToProjectSpec < ActiveRecord::Migration[6.0]
  def change
    remove_column :project_specs, :section_id
    remove_column :project_specs, :item_id
    remove_column :project_specs, :subitem_id
    remove_column :project_specs, :product_id
  end
end
