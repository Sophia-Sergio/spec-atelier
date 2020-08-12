module Company
  class Client < Company::Common
    has_many :products, foreign_key: 'brand_id', dependent: :destroy
    validates :name, :url, :contact_info, :type, :description, :email, presence: true
  end
end