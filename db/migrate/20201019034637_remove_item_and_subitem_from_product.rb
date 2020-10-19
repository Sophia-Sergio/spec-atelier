class RemoveItemAndSubitemFromProduct < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :subitem_id
    remove_column :products, :item_id
  end
end
