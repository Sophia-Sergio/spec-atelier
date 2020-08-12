module Company
  class Brand < Company::Common
    has_many :products, foreign_key: 'brand_id', dependent: :destroy

    def logo_url
      files&.images&.find_by(kind: 'logo')
    end

    def formatted_addresses
      addresses.map {|address| [address.name, address.text, address.country, address.city].join("\n") }
    end
  end
end