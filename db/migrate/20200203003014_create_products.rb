class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :short_desc
      t.string :long_desc
      t.string :reference
      t.references :brand, null: false, foreign_key: { on_delete: :cascade }
      t.integer :price
      t.text :work_type, array: true, default: []
      t.text :room_type, array: true, default: []
      t.text :project_type, array: true, default: []
      t.text :tags, array: true, default: []
      t.timestamps
    end
  end
end
