class CreateBrandContactForms < ActiveRecord::Migration[6.0]
  def change
    create_table :brand_contact_forms do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :user_phone
      t.string :message

      t.timestamps
    end
  end
end
