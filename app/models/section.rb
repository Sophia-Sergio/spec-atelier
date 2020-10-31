class Section < ApplicationRecord
  has_many :items, dependent: :delete_all

  scope :with_products, -> { joins(:products).distinct }

  def products
    Product.where(id: items.joins(:product_items).pluck(:product_id))
  end

  def self.with_products
    query = <<-SQL
      INNER JOIN items ON sections.id = items.section_id
      INNER JOIN product_items ON items.id = product_items.item_id
    SQL
    Section.joins(query).distinct
  end
end
