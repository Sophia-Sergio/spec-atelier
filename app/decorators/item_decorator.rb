class ItemDecorator < ApplicationDecorator
  delegate :id, :name, :show_order, :code
end
