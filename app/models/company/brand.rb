module Company
  class Brand < Company::Common
    include PgSearch::Model

    has_many :products, foreign_key: 'company_id', dependent: :destroy
    has_many :addresses, as: :owner, dependent: :destroy
    validates :name, :url, :contact_info, :type, :description, :email, presence: true
    has_many :files, as: :owner, class_name: 'Attached::ResourceFile'if

    pg_search_scope :by_keyword,
      against: %i[name],
      using: { tsearch: { prefix: true, any_word: true } }

    def logo_url
      files&.images&.find_by(kind: 'logo')
    end

    def formatted_addresses
      addresses.map {|address| [address.name, address.text, address.country, address.city].join("\n") }
    end
  end
end