class AddClientToBrand < ActiveRecord::Migration[6.0]
  def change
    add_column :brands, :client_id, :integer
  end
end
