class Subitem < ApplicationRecord
  belongs_to :item
  has_many :product_subitems
  has_many :products, through: :product_subitems, dependent: :destroy

  scope :with_products, -> { joins(:products).where(products: { original_product_id: nil }) }
end
