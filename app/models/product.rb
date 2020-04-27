class Product < ApplicationRecord
  include MetaLookupTable

  belongs_to :brand
  belongs_to :subitem, optional: true
  has_one :item, through: :subitem
  has_one :section, through: :item
  has_many :images, as: :owner, class_name: 'Attached::Image', dependent: :destroy
  has_many :documents, as: :owner, class_name: 'Attached::Document', dependent: :destroy

end
