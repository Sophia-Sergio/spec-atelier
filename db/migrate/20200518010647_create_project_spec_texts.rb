class CreateProjectSpecTexts < ActiveRecord::Migration[6.0]
  def change
    create_table :project_spec_texts do |t|
      t.string      :text, null: false
      t.references  :project_spec_block, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
