class Subitem < ApplicationRecord
  belongs_to :item
  has_many :product_subitems
  has_many :products, through: :product_subitems, dependent: :destroy

  scope :with_products, -> { joins(:products).where(products: { original_product_id: nil }).distinct }
  scope :with_accessible_products, -> (user) {
    ability = Abilities::ProductAbility.new(user)
    products = Product.accessible_by(ability).select(:id)
    joins(:products).where(products: { id: products, original_product_id: nil }).distinct
  }

end
