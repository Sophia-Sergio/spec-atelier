class Address < ApplicationRecord
  acts_as_paranoid

  validates :text, presence: true
  validates :country, presence: true
  validates :city, presence: true
  belongs_to :owner, polymorphic: true
end
