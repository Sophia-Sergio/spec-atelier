class CreatePlanContactForms < ActiveRecord::Migration[6.0]
  def change
    create_table :plan_contact_forms, id: :uuid do |t|
      t.string :plan_type, null: false
      t.string :user_name, null: false
      t.string :items_total, null: false
      t.string :phone
      t.string :email, null: false
      t.string :message
      t.timestamps
    end
  end
end
