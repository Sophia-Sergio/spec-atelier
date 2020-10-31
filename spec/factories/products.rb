FactoryBot.define do
  factory :product do
    sequence(:name) {|n| "fake product #{n}" }
    brand { create(:brand) }
    client { create(:client) }
    long_desc { 'long desc' }
    price { 1000 }
    user { create(:user) }
    items { [create(:item)]}
  end
end
