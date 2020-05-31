class AddFieldsToBrand < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :description, :string
    add_column :brands, :address, :string
    add_column :brands, :country, :string
    add_column :brands, :phone, :hstore, default: {}, null: false
    add_column :brands, :web, :string
    add_column :brands, :email, :hstore, default: {}, null: false
    add_column :brands, :social_media, :hstore, default: {}, null: false
  end
end
