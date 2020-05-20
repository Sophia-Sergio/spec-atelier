module ProjectSpec
  class SpecText < ApplicationRecord
    def self.table_name_prefix
      'project_'
    end

    has_one :item, class_name: 'ProjectSpec::SpecItem', foreign_key: :spec_item_id, dependent: :destroy
  end
end