class CreateProjectSpecTexts < ActiveRecord::Migration[6.0]
  def change
    create_table :project_spec_texts do |t|
      t.string      :text, null: false
      t.timestamps
    end
  end
end
