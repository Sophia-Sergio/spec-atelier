FactoryBot.define do
  factory :product do
    sequence(:name) {|n| "fake product #{n}" }
    item { create(:item) }
    brand { create(:brand) }
    long_desc { 'long desc' }
    price { 1000 }
    user { create(:user) }
  end
end
