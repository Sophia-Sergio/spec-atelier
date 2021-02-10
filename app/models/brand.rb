class Brand < ApplicationRecord
  belongs_to :client
  has_many :products
end
