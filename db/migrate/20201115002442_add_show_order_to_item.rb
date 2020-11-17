class AddShowOrderToItem < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :show_order, :integer
  end
end
