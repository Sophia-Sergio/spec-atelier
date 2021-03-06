module Attached
  class File < ApplicationRecord
    acts_as_paranoid

    def self.table_name_prefix
      'attached_'
    end

    validates :name, presence: true
    validate :extension_accepted

    scope :by_extension, ->(extension) { where('name LIKE ?', "%.#{extension}%") }
    has_one :resource_file, class_name: 'Attached::ResourceFile', foreign_key: :attached_file_id, dependent: :destroy

    %w[image document].each do |e|
      define_method("#{e}?") { type.eql? "Attached::#{e.capitalize}" }
    end

    private

    def extension_accepted
      extension = ::File.extname(name).gsub('.', '')
      errors.add(:file, "Extensión #{extension} no aceptada") unless self.class::EXTENSIONS.include? extension
    end
  end
end
