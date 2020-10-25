class Section < ApplicationRecord
  has_many :items, dependent: :delete_all

  scope :with_products, -> { joins(:products).distinct }

  def products
    Product.where(id: items.joins(:product_items).pluck(:product_id))
  end
end
