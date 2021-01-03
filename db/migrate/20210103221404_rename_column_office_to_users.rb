class RenameColumnOfficeToUsers < ActiveRecord::Migration[6.0]
  def self.up
    rename_column :users, :office, :company
  end

  def self.down
    rename_column :users, :company, :office
  end
end
