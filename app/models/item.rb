class Item < ApplicationRecord
  belongs_to :section
  has_many :subitems
  has_many :products, dependent: :destroy

end
