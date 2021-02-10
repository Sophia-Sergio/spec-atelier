class AddClientToBrand < ActiveRecord::Migration[6.0]
  def change
    add_reference :brands, :client, foreign_key: true
  end
end
