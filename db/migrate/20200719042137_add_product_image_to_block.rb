class AddProductImageToBlock < ActiveRecord::Migration[6.0]
  def change
    add_column :project_spec_blocks, :product_image_id, :integer
  end
end
