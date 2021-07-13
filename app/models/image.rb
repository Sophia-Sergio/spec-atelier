class Image < ApplicationRecord
  has_one_attached :file
  validates :file, content_type: %w[image/jpg image/png image/jpeg]

  belongs_to :owner, polymorphic: true

  def thumb
    file.variant(resize_to_limit: [100, 100]).processed
  end

  def small
    file.variant(resize_to_limit: [300, 300]).processed
  end

  def medium
    file.variant(resize_to_limit: [500, 500]).processed
  end
end
