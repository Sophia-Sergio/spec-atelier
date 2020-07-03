class Address < ApplicationRecord
  validates :text, presence: true
  validates :country, presence: true
  validates :city, presence: true
  belongs_to :owner, polymorphic: true, optional: true
end
