class AddDataToProductStat < ActiveRecord::Migration[6.0]
  def change
    Product.all.select{|product| product.stats.nil? }.each do |product|
      product.create_stats
    end
  end
end
