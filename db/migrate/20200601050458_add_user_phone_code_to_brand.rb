class AddUserPhoneCodeToBrand < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :user_phone_code, :integer
  end
end
