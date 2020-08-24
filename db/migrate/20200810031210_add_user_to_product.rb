class AddUserToProduct < ActiveRecord::Migration[6.0]
  def up
    add_column :products, :user_id, :integer
    Product.where(user_id: nil).update(user_id: User.first.id) if User.first.present?
    change_column :products, :user_id, :integer, references: :user
  end

  def down
    remove_column :products, :user_id
  end
end
