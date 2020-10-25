class ProductSubitem < ApplicationRecord
  belongs_to :subitem
  belongs_to :product
end
