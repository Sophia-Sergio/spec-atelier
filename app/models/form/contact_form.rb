module Form
  class ContactForm < Form::ContactForm
    self.table_name = :contact_forms

    belongs_to :owner, polymorphic: true
    belongs_to :user

  end

end