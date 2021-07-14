class Item < ApplicationRecord
  belongs_to :section
  has_many :subitems
  has_many :product_items
  has_many :products, through: :product_items, dependent: :destroy
  has_one :block, foreign_key: 'spec_item_id', class_name: 'ProjectSpec::Block'
  has_many :files, as: :owner, class_name: 'Attached::ResourceFile' #TODO borrar cuando ya lea de la nueva tabla images

  has_one_attached :default_image
  validates :default_image, content_type: %w[image/jpg image/png image/jpeg]

  scope :with_products, -> { joins(:products).distinct }

  def image_url
    files&.find_by(kind: 'item_image')&.attached&.url
  end

end
