class Product < ApplicationRecord
  include MetaLookupTable
  include PgSearch::Model

  belongs_to :client, optional: true
  belongs_to :brand, optional: true
  # belongs_to :subitem, optional: true
  # belongs_to :item
  belongs_to :user
  has_one :block, foreign_key: 'spec_item_id', class_name: 'ProjectSpec::Block'
  # has_one :section, through: :item
  has_many :files, as: :owner, class_name: 'Attached::ResourceFile'
  has_many :contact_forms, as: :owner, class_name: 'Form::ContactForm'

  validates :name, :long_desc, presence: true
  validates :client_id, presence: true, unless: :brand_id
  validates :brand_id, presence: true, unless: :client_id

  pg_search_scope :by_keyword,
    against: %i[name short_desc long_desc reference],
    associated_against: { brand: :name },
    using: { tsearch: { prefix: true, any_word: true } }

  # scope :by_section,      ->(sections) { joins(:section).where(sections: { id: sections }) }
  # scope :by_item,         ->(items)    { joins(:item).where(items: { id: items }) }
  scope :by_project_type, ->(types)    { where("project_type && ?", "{#{ types.is_a?(Array) ? types.join(',') : types }}") }
  scope :by_room_type,    ->(types)    { where("room_type && ?", "{#{ types.is_a?(Array) ? types.join(',') : types }}") }
  # scope :by_subitem,      ->(subitems) { where(subitem_id: subitems) }
  scope :original,        ->           { where(original_product_id: nil) }

  enum created_reason: %i[brand_creation added_to_spec]

  def self.by_brand(brands)
    scoped_brands = joins(:brand).where(brands: { id: brands })
    scoped_clients = joins(:client).where(clients: { id: brands })
    Product.where(id: (scoped_brands + scoped_clients).uniq)
  end

  def images
    images = files.images&.pluck(:attached_file_id)
    Attached::Image.where(id: images).joins(:resource_file).includes(:resource_file).select('attached_files.*, attached_resource_files.order').order(:order).uniq
  end

  def documents
    documents = files.documents&.pluck(:attached_file_id)
    Attached::Document.where(id: documents)
                      .joins(:resource_file)
                      .includes(:resource_file)
                      .select('attached_files.*, attached_resource_files.order')
                      .order(:order)
  end

  def original_product
    self.class.find(original_product_id) if self.added_to_spec?
  end

  def spec_products
    self.class.where(original_product_id: self.id)
  end
end
