class CreateProjectSpecs < ActiveRecord::Migration[6.0]
  def change
    create_table :project_specs do |t|
      t.references :project, null: false, foreign_key: true
      t.references :section, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.references :subitem, null: false, foreign_key: true
      t.references :product, null: true, foreign_key: true

      t.timestamps
    end
  end
end
