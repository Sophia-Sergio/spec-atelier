class ChangeSeededProjectType < ActiveRecord::Migration[6.0]
  def change
    row = LookUpTable.find_by(category: 'project_type', value: 'commercial')
    row&.update(value: 'hotel', translation_spa: 'hotel')

    LookUpTable.find_by(category: 'project_type', value: 'office')&.delete
  end
end
