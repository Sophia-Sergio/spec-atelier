class Product < ApplicationRecord
  include MetaLookupTable
  include PgSearch::Model

  belongs_to :brand
  belongs_to :subitem, optional: true
  belongs_to :item
  has_one :section, through: :item
  has_many :images, as: :owner, class_name: 'Attached::Image', dependent: :destroy
  has_many :documents, as: :owner, class_name: 'Attached::Document', dependent: :destroy

  validates :name, :brand, :item, :long_desc, :price, presence: true

  pg_search_scope :by_keyword,
    against: %i[name short_desc long_desc reference],
    associated_against: { brand: :name },
    using: { tsearch: { prefix: true, any_word: true } }

  scope :by_brand,        ->(brands)   { joins(:brand).where(brands: { id: brands }) }
  scope :by_section,      ->(sections) { joins(:section).where(sections: { id: sections }) }
  scope :by_item,         ->(items)    { joins(:item).where(items: { id: items }) }
  scope :by_project_type, ->(types)    { where("project_type && ?", "{#{ types.is_a?(Array) ? types.join(',') : types }}") }
  scope :by_room_type,    ->(types)    { where("room_type && ?", "{#{ types.is_a?(Array) ? types.join(',') : types }}") }

end
