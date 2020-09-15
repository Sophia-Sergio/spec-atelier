class AddProductOrderToProjectSpecBlock < ActiveRecord::Migration[6.0]
  def change
    add_column :project_spec_blocks, :section_order, :integer
    add_column :project_spec_blocks, :item_order, :integer
    add_column :project_spec_blocks, :product_order, :integer
  end
end
