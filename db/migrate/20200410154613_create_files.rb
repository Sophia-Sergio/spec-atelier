class CreateFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :attached_files do |t|
      t.string      :url, null: false
      t.string      :name, null: false
      t.string      :type, null: false
      t.timestamp   :deleted_at
      t.timestamps
    end
  end
end
