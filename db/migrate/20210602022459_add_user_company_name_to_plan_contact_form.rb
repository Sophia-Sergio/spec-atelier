class AddUserCompanyNameToPlanContactForm < ActiveRecord::Migration[6.0]
  def change
    add_column :plan_contact_forms, :user_company_name, :string
  end
end
