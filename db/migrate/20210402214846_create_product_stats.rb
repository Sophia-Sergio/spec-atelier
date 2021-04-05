class CreateProductStats < ActiveRecord::Migration[6.0]
  def change
    create_table :product_stats, id: :uuid do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :dwg_downloads, default: 0
      t.integer :bim_downloads, default: 0
      t.integer :pdf_downloads, default: 0
      t.integer :visualizations, default: 0
      t.integer :used_on_spec, default: 0
      t.timestamps
    end
  end
end
