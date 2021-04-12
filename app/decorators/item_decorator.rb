class ItemDecorator < ApplicationDecorator
  delegate :id, :name, :show_order, :code
  new_keys :subitems

  def subitems
    model.subitems.with_products.map {|subitem| { id: subitem.id, name: subitem.name } }
  end
end
