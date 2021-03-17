class BrandDecorator < ApplicationDecorator
  delegate :id, :name, :description
end
