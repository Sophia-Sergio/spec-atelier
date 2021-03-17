class Brand < ApplicationRecord
  include PgSearch::Model

  belongs_to :client, optional: true
  validates :name, presence: true
  has_many :products

  scope :with_client, -> { where.not(client_id: nil) }
  pg_search_scope :by_keyword,
                  against: %i[name],
                  using: { tsearch: { prefix: true, any_word: true } }
end
