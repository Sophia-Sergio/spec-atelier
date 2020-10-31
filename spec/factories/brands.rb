FactoryBot.define do
  factory :brand, class: 'Brand' do
    sequence(:name) {|n| "fake brand #{n}" }
  end
end
