class CreateClients < ActiveRecord::Migration[6.0]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :description
      t.string :url
      t.hstore :phone
      t.hstore :email
      t.string :contact_info
      t.hstore :social_media
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
