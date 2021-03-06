module Form
  class ContactForm < ApplicationRecord
    self.table_name = :contact_forms

    belongs_to :owner, polymorphic: true
    belongs_to :user

    validates :message, presence: true

  end

end
