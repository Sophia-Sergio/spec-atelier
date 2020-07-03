class AddFieldsToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :social_media, :hstore, default: {}, null: false
  end
end
