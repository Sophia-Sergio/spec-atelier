class CreateImages < ActiveRecord::Migration[6.1]
  def change
    create_table :images do |t|
      t.references :owner, polymorphic: true, null: false
      t.integer :order, default: 0, null: false
      t.timestamps
    end
  end
end
