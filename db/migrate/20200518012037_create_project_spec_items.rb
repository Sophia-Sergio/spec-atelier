class CreateProjectSpecItems < ActiveRecord::Migration[6.0]
  def change
    create_table :project_spec_items do |t|
      t.string :spec_item_type
      t.integer :spec_item_id
      t.references :project_spec, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
