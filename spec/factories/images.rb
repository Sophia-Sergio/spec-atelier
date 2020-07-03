FactoryBot.define do
  factory :image, class: 'Attached::Image' do
    sequence(:name) {|n| "default_name_#{n}.jpg" }
    sequence(:url) {|n| "https://default_name_#{n}.jpg" }
  end
end
