FactoryBot.define do
  factory :product_subitem do
    product { create(:product) }
    subitem { create(:subitem) }
  end
end
