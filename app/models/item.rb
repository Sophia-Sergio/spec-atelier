class Item < ApplicationRecord
  belongs_to :section
  has_many :subitems
  has_many :products, dependent: :destroy
  has_one :block, foreign_key: 'spec_item_id', class_name: 'ProjectSpec::Block'
  has_many :files, as: :owner, class_name: 'Attached::ResourceFile'

  def image_url
    files&.find_by(kind: 'item_image')&.attached&.url
  end

end
