FactoryBot.define do
  factory :brand, class: 'Brand' do
    sequence(:name) {|n| "fake brand #{n}" }

    trait :with_client do
      client { create(:client) }
    end
  end
end
