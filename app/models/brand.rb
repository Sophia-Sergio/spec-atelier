class Brand < ApplicationRecord
  belongs_to :client, optional: true
  validates :name, presence: true
  has_many :products

  scope :with_client, -> { where.not(client_id: nil) }
end
