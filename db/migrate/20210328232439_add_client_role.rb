class AddClientRole < ActiveRecord::Migration[6.0]
  def change
    Role.create(name: 'client')
  end
end
