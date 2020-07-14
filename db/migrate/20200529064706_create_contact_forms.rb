class CreateContactForms < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_forms do |t|
      t.references :owner, polymorphic: true
      t.references :user, null: false, foreign_key: true
      t.string :user_phone
      t.string :message
      t.string :type

      t.timestamps
    end
  end
end
