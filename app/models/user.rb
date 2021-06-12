class User < ApplicationRecord
  include RolifyAdmin
  include PgSearch::Model

  rolify
  has_secure_password
  after_create :assign_default_role
  validates :email, presence: true, uniqueness: true
  has_one :session, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :specifications, through: :projects
  has_many :products
  has_many :user_clients
  has_many :clients, through: :user_clients, dependent: :destroy
  has_one :file, as: :owner, class_name: 'Attached::ResourceFile', dependent: :destroy

  pg_search_scope :by_keyword,
    against: %i[first_name last_name email],
    using: { tsearch: { prefix: true, any_word: true } }

  def generate_password_token!
    update(reset_password_token: SecureRandom.hex(10), reset_password_sent_at: Time.zone.now)
  end

  def password_token_valid?
    (reset_password_sent_at + 4.hours) > Time.now.utc
  end

  def reset_password!(password)
    update(reset_password_token: nil, password: password)
  end

  def active?
    session.active?
  end

  def name
    "#{first_name.capitalize} #{last_name.capitalize}" if first_name.present? && last_name.present?
  end

  def profile_image
    file&.image
  end

  private

  def assign_default_role
    add_role(:user) if roles.blank?
  end
end
