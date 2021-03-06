class SectionDecorator < ApplicationDecorator
  delegate :id, :name, :eng_name, :show_order, :code
end
