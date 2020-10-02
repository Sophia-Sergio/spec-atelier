class AddCodeToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :code, :string
  end
end
