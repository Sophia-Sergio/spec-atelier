FactoryBot.define do
  factory :arrached_file do
    sequence(:order) {|n| n }
    sequence(:name) {|n| "default_name_#{n}" }
    sequence(:url) {|n| "https://example_#{n}.jpg" }
  end
end
