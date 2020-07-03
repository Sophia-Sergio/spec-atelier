module ProjectSpec
  class Text < ApplicationRecord
    def self.table_name_prefix
      'project_spec_'
    end

    has_one :item, class_name: 'ProjectSpec::Item', foreign_key: :spec_item_id, dependent: :destroy
  end
end