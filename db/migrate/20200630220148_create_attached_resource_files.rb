class CreateAttachedResourceFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :attached_resource_files do |t|
      t.references :attached_file, null: false, foreign_key: true
      t.references :owner, polymorphic: true,  null: true
      t.string :kind
      t.integer :order, default: 0
      t.timestamp :deleted_at
      t.timestamps
    end
  end
end
