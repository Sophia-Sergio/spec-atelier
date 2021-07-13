class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :short_desc
      t.string :long_desc
      t.string :reference
      t.integer :brand_id, foreign_key: { on_delete: :cascade }
      t.integer :client_id, foreign_key: { on_delete: :cascade }
      t.references :item, null: false, foreign_key: { on_delete: :cascade }
      t.references :subitem, foreign_key: { on_delete: :cascade }
      t.integer :price
      t.timestamp :deleted_at
      t.text :work_type, array: true, default: []
      t.text :room_type, array: true, default: []
      t.text :project_type, array: true, default: []
      t.text :tags, array: true, default: []
      t.timestamps
    end
  end
end
