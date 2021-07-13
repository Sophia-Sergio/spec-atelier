class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.string :name
      t.string :text
      t.string :country
      t.string :city
      t.references  :owner, polymorphic: true,  null: true
      t.integer     :order, default: 0
      t.timestamp   :deleted_at
      t.timestamps
    end
  end
end
