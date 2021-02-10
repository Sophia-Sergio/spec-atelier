FactoryBot.define do
  factory :brand, class: 'Brand' do
    sequence(:name) {|n| "fake brand #{n}" }
    client { create(:client) }
  end
end
