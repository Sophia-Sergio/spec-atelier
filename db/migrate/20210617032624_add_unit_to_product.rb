class AddUnitToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :unit, :string
  end
end
