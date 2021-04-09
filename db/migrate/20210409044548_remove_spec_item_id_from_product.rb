class RemoveSpecItemIdFromProduct < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :spec_item_id
  end
end
