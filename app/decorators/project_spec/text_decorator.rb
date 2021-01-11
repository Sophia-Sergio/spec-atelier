module ProjectSpec
  class TextDecorator < ApplicationDecorator
    delegate :id, :text
  end
end
