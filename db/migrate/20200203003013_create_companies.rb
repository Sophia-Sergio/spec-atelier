class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :description
      t.string :url
      t.string :phone
      t.string :email
      t.string :type
      t.string :contact_info
      t.timestamps
    end
  end
end
