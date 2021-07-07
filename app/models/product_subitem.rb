class ProductSubitem < ApplicationRecord
  acts_as_paranoid

  belongs_to :subitem
  belongs_to :product
end
