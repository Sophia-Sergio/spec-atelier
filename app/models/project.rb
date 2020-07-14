class Project < ApplicationRecord
  include MetaLookupTable
  include PgSearch::Model

  belongs_to :user
  has_one :specification, class_name: 'ProjectSpec::Specification'
  default_scope { where(soft_deleted: false) }
  enum status: { active: 1, closed: 0 }
  enum visibility: { public_available: 0, creator_only: 1 }

  pg_search_scope :by_keyword,
    against: %i[name description city country],
    using: { tsearch: { prefix: true, any_word: true } }

  scope :by_project_type, ->(types)    { where(project_type: types) }
  scope :by_work_type,    ->(types)    { where(work_type: types) }

  after_create :create_specification

  def create_specification
    ProjectSpec::Specification.create(project: self)
  end
end
