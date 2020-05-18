module ProjectSpec
  class SpecItem < ApplicationRecord
    def self.table_name_prefix
      'project_'
    end

    belongs_to :project_spec, class_name: 'ProjectSpec::Specification'
    belongs_to :user
    belongs_to :spec_item, polymorphic: true
  end
end
