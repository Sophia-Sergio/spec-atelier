class ProductStat < ApplicationRecord
  acts_as_paranoid

  belongs_to :product
end
