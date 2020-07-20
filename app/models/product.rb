class Product < ApplicationRecord
  include MetaLookupTable
  include PgSearch::Model

  belongs_to :brand, foreign_key: 'company_id', class_name: 'Company::Brand'
  belongs_to :subitem, optional: true
  belongs_to :item
  has_one :section, through: :item
  has_many :files, as: :owner, class_name: 'Attached::ResourceFile'
  validates :name, :brand, :item, :long_desc, presence: true
  has_many :contact_forms, as: :owner, class_name: 'Form::ContactForm'

  pg_search_scope :by_keyword,
    against: %i[name short_desc long_desc reference],
    associated_against: { brand: :name },
    using: { tsearch: { prefix: true, any_word: true } }

  scope :by_brand,        ->(brands)   { joins(:brand).where(companies: { id: brands }) }
  scope :by_section,      ->(sections) { joins(:section).where(sections: { id: sections }) }
  scope :by_item,         ->(items)    { joins(:item).where(items: { id: items }) }
  scope :by_project_type, ->(types)    { where("project_type && ?", "{#{ types.is_a?(Array) ? types.join(',') : types }}") }
  scope :by_room_type,    ->(types)    { where("room_type && ?", "{#{ types.is_a?(Array) ? types.join(',') : types }}") }

  before_validation(on: :create) do
    self.item = subitem.item if subitem.present?
  end

  def images
    images = files.images&.pluck(:attached_file_id)
    Attached::Image.where(id: images)
                   .joins(:resource_file)
                   .select('attached_resource_files.order')
                   .distinct
                   .order('attached_resource_files.order')
  end

  def documents
    documents = files.documents&.pluck(:attached_file_id)
    Attached::Document.where(id: documents)
                      .joins(:resource_file)
                      .select('attached_resource_files.order')
                      .distinct
                      .order('attached_resource_files.order')
  end
end
