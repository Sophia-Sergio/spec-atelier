class AddSpecItemToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :spec_item_id, :integer
  end
end
