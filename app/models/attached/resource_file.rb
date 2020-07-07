module Attached
  class ResourceFile < ApplicationRecord
    def self.table_name_prefix
      'attached_'
    end

    belongs_to :owner, polymorphic: true, optional: true
    validates :order, uniqueness: { scope: %i[owner kind] }, presence: true, if: -> { kind != 'product_document' }
    belongs_to :attached, class_name: 'Attached::File', foreign_key: :attached_file_id, dependent: :destroy

    scope :images, -> { joins(:attached).where(attached_files: { type: 'Attached::Image' }).positioned }
    scope :documents, -> { joins(:attached).where(attached_files: { type: 'Attached::Document' }).positioned }

    scope :positioned, -> { order(order: :asc) }

    before_validation(on: :create) do
      if attached.image? && owner.class == Product
        owner = self.owner.class.find(self.owner.id)
        self.order = owner.files.present? ? owner.files.map(&:order).max + 1 : 0
      end
    end

    def image
      attached if attached.image?
    end

    def document
      attached if attached.document?
    end

  end
end