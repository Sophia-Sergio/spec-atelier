class Brand < ApplicationRecord
  include PgSearch::Model

  has_many :products
  has_many :brand_contact_forms
  validates :name, presence: true

  pg_search_scope :by_keyword,
    against: %i[name],
    using: { tsearch: { prefix: true, any_word: true } }

end
