class AddRelatedCategoryToLookupTable < ActiveRecord::Migration[6.0]
  def change
    add_column :lookup_tables, :related_category, :string
    add_column :lookup_tables, :related_category_codes, :text, array: true, default: []
  end
end