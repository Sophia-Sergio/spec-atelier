class AddCreatedReasonAndOriginalProductToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :created_reason, :integer
    add_column :products, :original_product_id, :integer
  end
end
