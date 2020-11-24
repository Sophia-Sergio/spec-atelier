class LookupTable < ApplicationRecord
  CATEGORIES = %w[project_type work_type room_type].freeze

  scope :by_category, ->(category) { where(category: category) }
  scope :by_project_type, ->(types) { where("
    related_category = 'project_type' and
    related_category_codes && ?", "{#{types.is_a?(Array) ? types.join(',') : types}}")
  }

end
