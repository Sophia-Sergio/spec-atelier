FactoryBot.define do
  factory :product do
    sequence(:name) {|n| "fake product #{n}" }
    subitem { create(:subitem) }
    brand { create(:brand) }
    long_desc { 'long desc' }
    price { 1000 }
  end
end
