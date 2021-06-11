class AddImpersonatedToSession < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :impersonated, :boolean, default: false
  end
end
