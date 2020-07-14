module ProjectSpec
  class Text < ApplicationRecord
    def self.table_name_prefix
      'project_spec_'
    end

    has_one :block, class_name: 'ProjectSpec::Block', as: :spec_item, dependent: :destroy
    belongs_to :block_item, class_name: 'ProjectSpec::Block', foreign_key: 'project_spec_block_id'
  end
end