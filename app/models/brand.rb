class Brand < ApplicationRecord
  belongs_to :client, optional: true
  has_many :products
end
