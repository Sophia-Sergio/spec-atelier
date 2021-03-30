class CreateUserClients < ActiveRecord::Migration[6.0]
  def change
    create_table :user_clients, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
