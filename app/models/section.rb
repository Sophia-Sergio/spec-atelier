class Section < ApplicationRecord
  has_many :items, dependent: :delete_all
  has_many :products, through: :items

  scope :with_products, -> { joins(:products).distinct }

end
