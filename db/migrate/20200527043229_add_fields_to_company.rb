class AddFieldsToCompany < ActiveRecord::Migration[6.0]
  def up
    add_column :companies, :social_media, :hstore, default: {}
    change_column_null :companies, :phone, ''
    change_column :companies, :phone, "hstore USING phone::hstore"
    change_column_null :companies, :email, ''
    change_column :companies, :email, "hstore USING email::hstore"
  end

  def down
    change_column :companies, :phone, :string, default: ''
    change_column :companies, :email, :string, default: ''
  end
end
