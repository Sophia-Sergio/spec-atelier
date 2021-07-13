class AddDeletedAtToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :deleted_at, :timestamp unless column_exists?(:products, :deleted_at)
    add_column :product_stats, :deleted_at, :timestamp unless column_exists?(:product_stats, :deleted_at)
    add_column :product_items, :deleted_at, :timestamp unless column_exists?(:product_items, :deleted_at)
    add_column :product_subitems, :deleted_at, :timestamp unless column_exists?(:product_subitems, :deleted_at)
    add_column :attached_resource_files, :deleted_at, :timestamp unless column_exists?(:attached_resource_files, :deleted_at)
    add_column :attached_files, :deleted_at, :timestamp unless column_exists?(:attached_files, :deleted_at)
    add_column :clients, :deleted_at, :timestamp unless column_exists?(:clients, :deleted_at)
    add_column :brands, :deleted_at, :timestamp unless column_exists?(:brands, :deleted_at)
    add_column :addresses, :deleted_at, :timestamp unless column_exists?(:addresses, :deleted_at)
  end
end
