class Client < ApplicationRecord
  acts_as_paranoid
  include PgSearch::Model

  has_many :products, -> { original }, inverse_of: :client, dependent: :destroy
  has_many :brands
  validates :name, :url, :contact_info, :description, :email, :phone, presence: true
  has_many :contact_forms, as: :owner, class_name: 'Form::ContactForm'
  has_many :addresses, as: :owner, dependent: :destroy
  has_many :files, as: :owner, class_name: 'Attached::ResourceFile'

  pg_search_scope :by_keyword,
                  against: %i[name],
                  using: { tsearch: { prefix: true, any_word: true } }

  def default_email
    email["main"] if email.present?
  end

  def formatted_addresses
    addresses.map {|address| [address.name, address.text, address.country, address.city].join("\n") }
  end

  def product_images
    Attached::Image.where(id: files.where(kind: 'brand_show').select(:attached_file_id))
  end

  def logo_url
    files&.images&.find_by(kind: 'logo')&.image&.url
  end

  def main_phone
    phone["main"]
  end
end
