class CreateProjectSpecBlocks < ActiveRecord::Migration[6.0]
  def change
    create_table :project_spec_blocks, id: :uuid do |t|
      t.references :spec_item, polymorphic: true, null: true
      t.references :project_spec, null: false, foreign_key: true
      t.integer :order, null: false, default: 0
      t.references :section, foreign_key: true
      t.references :item, foreign_key: true
      t.timestamps
    end
  end
end
