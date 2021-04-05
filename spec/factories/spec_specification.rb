FactoryBot.define do
  factory :spec_specification, class: 'ProjectSpec::Specification' do
    project { create(:project) }
  end
end
