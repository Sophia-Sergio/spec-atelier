FactoryBot.define do
    factory :product_item do
      product { create(:product) }
      item { create(:item) }
    end
  end
  