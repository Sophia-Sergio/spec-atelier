class Brand < ApplicationRecord
  has_many :products
  scope :search, ->(keywords) { where('name LIKE ?', "%#{keywords}%") }
  validates :name, presence: true
end
