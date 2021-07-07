class ProductItem < ApplicationRecord
  acts_as_paranoid

  belongs_to :item
  belongs_to :product
end
