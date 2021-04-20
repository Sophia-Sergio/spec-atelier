class CreateProjectConfigs < ActiveRecord::Migration[6.0]
  def up
    create_project_configs
    populate_table
  end

  def down
    drop_table :project_configs
  end

  private

  def create_project_configs
    create_table :project_configs do |t|
      t.json :visible_attrs, null: false
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end

  def populate_table
    Project.all.select {|a| a.config.nil? }.each do |project|
      project.create_config(visible_attrs: visible_attrs)
    end
  end

  def visible_attrs
    {
      "product" => {
        "all" => true,
        "short_desc" => false,
        "long_desc" => true,
        "reference" => true,
        "brand" => false
      }
    }
  end
end
