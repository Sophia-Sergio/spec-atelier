class CreateProductSubitems < ActiveRecord::Migration[6.0]
  def change
    create_table :product_subitems, id: :uuid do |t|
      t.references :subitem, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.timestamp :deleted_at
      t.timestamps
    end
  end
end
