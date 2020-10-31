class AddCodeToSubitems < ActiveRecord::Migration[6.0]
  def change
    add_column :subitems, :code, :string
  end
end
