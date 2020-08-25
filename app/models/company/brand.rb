module Company
  class Brand < Company::Common
    has_many :products, foreign_key: 'brand_id', dependent: :destroy

    def logo_url
      files&.images&.find_by(kind: 'logo')
    end
  end
end