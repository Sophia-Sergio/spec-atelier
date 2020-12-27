FactoryBot.define do
  factory :product do
    sequence(:name) {|n| "fake product #{n}" }
    brand { create(:brand) }
    client { create(:client) }
    long_desc { 'long desc' }
    price { 1000 }
    user { create(:user, :superadmin) }
    items { [create(:item)]}
    spec_item { create(:item)}

    trait :used_on_spec do
      original_product_id { create(:product).id }
      created_reason { 1 }
    end
  end
end
