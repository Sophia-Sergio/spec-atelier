class ItemDecorator < ApplicationDecorator
  delegate :id, :name, :show_order, :code
  new_keys :subitems

  def subitems
    user = context[:user]
    model.subitems.with_accessible_products(user).map {|subitem| { id: subitem.id, name: subitem.name } }
  end
end
