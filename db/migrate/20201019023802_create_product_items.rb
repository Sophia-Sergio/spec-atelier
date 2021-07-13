class CreateProductItems < ActiveRecord::Migration[6.0]
  def change
    create_table :product_items, id: :uuid do |t|
      t.references :item, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
