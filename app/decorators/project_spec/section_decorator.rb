module ProjectSpec
  class SectionDecorator < ApplicationDecorator
    delegate :id
    new_keys :name

    def name
      "#{model.block.section_order}. #{model.name}"
    end
  end
end
