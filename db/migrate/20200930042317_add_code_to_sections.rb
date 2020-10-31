class AddCodeToSections < ActiveRecord::Migration[6.0]
  def change
    add_column :sections, :code, :string
  end
end
