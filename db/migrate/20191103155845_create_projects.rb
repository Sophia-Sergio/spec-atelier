class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :project_type, null: false
      t.integer :work_type, null: false
      t.string :country
      t.string :city
      t.string :description
      t.date :delivery_date
      t.integer :status, default: 1, null: false
      t.integer :visibility, default: 0, null: false
      t.boolean :soft_deleted, default: false, null: false
      t.timestamps
    end
  end
end
