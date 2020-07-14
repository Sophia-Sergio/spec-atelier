module Attached
  class File < ApplicationRecord
    def self.table_name_prefix
      'attached_'
    end

    validates :name, presence: true
    scope :by_extension, ->(extension) { where('name LIKE ?', "%.#{extension}%")}
    has_one :resource_file, class_name: 'Attached::ResourceFile', foreign_key: :attached_file_id

    %w[image document].each do |e|
      define_method("#{e}?") { type.eql? "Attached::#{e.capitalize}" }
    end
  end
end
