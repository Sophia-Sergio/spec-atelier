class Item < ApplicationRecord
  belongs_to :section
  has_many :subitems
  has_many :products, dependent: :destroy

  has_many :files, as: :owner, class_name: 'Attached::ResourceFile'

  def image_url
    files&.find_by(kind: 'item_image')&.attached&.url
  end

end
