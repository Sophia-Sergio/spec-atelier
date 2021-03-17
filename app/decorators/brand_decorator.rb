class BrandDecorator < ApplicationDecorator
  delegate :id, :name, :description
  new_keys :products_count

  def products_count
    model.products.count
  end

end
