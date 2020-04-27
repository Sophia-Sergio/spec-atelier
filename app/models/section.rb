class Section < ApplicationRecord
  has_many :items, dependent: :delete_all
  has_many :products, through: :items
end
