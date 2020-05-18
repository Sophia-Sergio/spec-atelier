module Attached
  class File < ApplicationRecord
    belongs_to :owner, polymorphic: true, optional: true
    scope :positioned, -> { order(order: :asc) }
    validates :name, uniqueness: { scope: %i[owner type] }
    validates :order, uniqueness: { scope: %i[owner type] }

    scope :by_extension, ->(extension) { where("name LIKE ?", "%.#{extension}%")}

  end
end
