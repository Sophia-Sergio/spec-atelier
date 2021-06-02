class Project < ApplicationRecord
  include MetaLookupTable
  include PgSearch::Model

  belongs_to :user
  has_one :specification, class_name: 'ProjectSpec::Specification'
  has_one :config, class_name: 'ProjectConfig'
  default_scope { where(soft_deleted: false) }
  enum status: { active: 1, closed: 0 }
  enum visibility: { public_available: 0, creator_only: 1 }

  pg_search_scope :by_keyword,
    against: %i[name description city country],
    using: { tsearch: { prefix: true, any_word: true } }

  delegate :name, to: :user, prefix: true
  delegate :email, to: :user, prefix: true

  scope :by_project_type, ->(types)    { where(project_type: types) }
  scope :by_work_type,    ->(types)    { where(work_type: types) }
  scope :by_product, lambda {|products|
    product_ids = Product.where(original_product_id: products).pluck(:id)
    joins(specification: :blocks)
      .where(project_spec_blocks: { spec_item_id: product_ids, spec_item_type: 'Product' })
      .distinct
  }
  before_create :work_type_default
  after_create :create_specification, :create_project_config

  def create_specification
    ProjectSpec::Specification.create(project: self)
  end

  def work_type_default
    self.work_type = 1
  end

  def products
    specification.products
  end

  private

  def create_project_config
    create_config(
      visible_attrs: {
        product: {
          default: true,
          short_desc: false,
          long_desc: true,
          reference: true,
          brand: true
        }
      }
    )
  end
end
