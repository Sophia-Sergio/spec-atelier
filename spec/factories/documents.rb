FactoryBot.define do
  factory :document, class: 'Attached::Document' do
    sequence(:order) {|n| n }
    sequence(:name) {|n| "default_name_#{n}.pdf" }
    sequence(:url) {|n| "https://example_#{n}.pdf" }
  end
end
