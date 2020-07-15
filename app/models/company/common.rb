module Company
  class Common < ApplicationRecord
    self.table_name = 'companies'

    has_many :contact_forms, as: :owner, class_name: 'Form::ContactForm'

  end
end