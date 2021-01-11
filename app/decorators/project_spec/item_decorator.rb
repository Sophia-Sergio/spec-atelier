module ProjectSpec
  class ItemDecorator < ApplicationDecorator
    delegate :id
    new_keys :name

    def name
      "#{model.block.section_order}.#{model.block.item_order}. #{model.name}"
    end
  end
end
