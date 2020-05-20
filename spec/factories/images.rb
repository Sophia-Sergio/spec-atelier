FactoryBot.define do
  factory :image, class: 'Attached::Image' do
    sequence(:order) {|n| n }
    sequence(:name) {|n| "default_name_#{n}.jpg" }
    sequence(:url) {|n| "https://example_#{n}.jpg" }
  end
end
