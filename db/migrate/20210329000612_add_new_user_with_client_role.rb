class AddNewUserWithClientRole < ActiveRecord::Migration[6.0]
  def change
    paul = User.create(
      email: 'paul.berzilon@gmail.com',
      password: 'uEk]<6kC}5S#aV=H',
      first_name: 'Paul',
      last_name: 'Eaton'
    )

    sergio = User.create(
      email: 'san.storres@gmail.com',
      password: '*t+z&MmA&m7EVPCZ',
      first_name: 'Sergio',
      last_name: 'Torres'
    )
    paul.add_role(:client)
    paul.add_role(:superadmin)
    sergio.add_role(:superadmin)
  end
end
