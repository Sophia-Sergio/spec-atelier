class Product < ApplicationRecord
  include MetaLookupTable
  include PgSearch::Model

  belongs_to :client, optional: true
  belongs_to :brand, optional: true
  has_many :product_items, dependent: :destroy
  has_many :product_subitems, dependent: :destroy
  has_many :subitems, through: :product_subitems
  has_many :items, through: :product_items
  has_many :sections, through: :items
  belongs_to :spec_item, class_name: 'Item', optional: true
  belongs_to :user
  has_many :files, as: :owner, class_name: 'Attached::ResourceFile', dependent: :destroy
  has_many :contact_forms, as: :owner, class_name: 'Form::ContactForm', dependent: :destroy
  has_one :stats, class_name: 'ProductStat', dependent: :destroy

  validates :name, :long_desc, presence: true
  validates :client_id, presence: true, unless: :brand_id
  validates :brand_id, presence: true, unless: :client_id

  delegate :name, to: :brand, prefix: true, allow_nil: true
  delegate :name, to: :client, prefix: true, allow_nil: true
  delegate :used_on_spec, to: :stats, prefix: true, allow_nil: true
  delegate :dwg_downloads, to: :stats, prefix: true, allow_nil: true
  delegate :pdf_downloads, to: :stats, prefix: true, allow_nil: true
  delegate :bim_downloads, to: :stats, prefix: true, allow_nil: true
  delegate :visualizations, to: :stats, prefix: true, allow_nil: true

  pg_search_scope :by_keyword,
    against: %i[name short_desc long_desc reference],
    associated_against: { brand: :name },
    using: { tsearch: { prefix: true, any_word: true } }

  scope :by_section,      ->(sections) { joins(:sections).where(sections: { id: sections }) }
  scope :by_item,         ->(items)    { joins(:items).where(items: { id: items }) }
  scope :by_project_type, ->(types)    { where("project_type && ?", "{#{ types.is_a?(Array) ? types.join(',') : types }}") }
  scope :by_room_type,    ->(types)    { where("room_type && ?", "{#{ types.is_a?(Array) ? types.join(',') : types }}") }
  scope :by_subitem,      ->(subitems) { joins(:subitems).where(subitems: { id: subitems }) }
  scope :by_brand,        ->(brands)   { joins(:brand).where(brands: { id: brands }) }
  scope :by_client,       ->(clients)  { joins(:client).where(clients: { id: clients }) }
  scope :original,        ->           { where(original_product_id: nil) }
  scope :used_on_spec,    ->           { where.not(original_product_id: nil) }
  scope :used_on_spec_original, ->     { where(id: used_on_spec.select(:original_product_id).distinct) }
  scope :system_owned,    ->           { joins(user: :roles).where(roles: { name: 'superadmin' }) }
  scope :by_user,         ->(user)     { where(user: user) }
  scope :readable,        ->           { original.system_owned }
  scope :readable_by,     ->(user)     { union(readable, original.by_user(user)) }

  scope :most_used, lambda {
    orderded_ids = unscoped.used_on_spec.select('original_product_id, COUNT(original_product_id) AS product_count')
                           .group(:original_product_id)
                           .order('product_count DESC')
                           .map(&:original_product_id)
    original.find_ordered(orderded_ids)
  }
  scope :by_specification, lambda {|specs|
    query = <<-SQL
      INNER JOIN project_spec_blocks ON products.id = project_spec_blocks.spec_item_id
      INNER JOIN project_specs ON project_spec_blocks.project_spec_id = project_specs.id
    SQL
    ids = unscoped.joins(query)
                  .where(project_specs: { id: specs }, project_spec_blocks: { spec_item_type: 'Product' } )
                  .pluck(:original_product_id)
    unscoped.original.where(id: ids)
  }

  after_create :create_stats, if: proc { original_product_id.nil? }
  after_create :used_on_spec_stat_update, if: proc { original_product_id.present? }
  after_destroy :used_on_spec_stat_destroy, if: proc { original_product_id.present? }

  enum created_reason: %i[brand_creation added_to_spec]

  def block
    ProjectSpec::Block.products.find_by(spec_item: self)
  end

  def images
    images = files.images&.pluck(:attached_file_id)
    Attached::Image
      .where(id: images)
      .joins(:resource_file)
      .includes(:resource_file)
      .select('attached_files.*, attached_resource_files.order')
      .order(:order).uniq
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

  private

  def used_on_spec_stat_update
    original_product.stats.update(used_on_spec: original_product.stats_used_on_spec + 1)
  end

  def used_on_spec_stat_destroy
    original_product.stats.update(used_on_spec: original_product.stats_used_on_spec - 1)
  end
end
