module Company
  class Common < ApplicationRecord
    self.table_name = 'companies'
    include PgSearch::Model

    has_many :contact_forms, as: :owner, class_name: 'Form::ContactForm'
    has_many :addresses, as: :owner, dependent: :destroy
    has_many :files, as: :owner, class_name: 'Attached::ResourceFile'

    pg_search_scope :by_keyword,
      against: %i[name],
      using: { tsearch: { prefix: true, any_word: true } }

    def formatted_addresses
      addresses.map {|address| [address.name, address.text, address.country, address.city].join("\n") }
    end

    def default_email
      email["main"] if email.present?
    end
  end
end