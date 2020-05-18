FactoryBot.define do
  factory :project_spec_specification, class: 'ProjectSpec::Specification' do
    project { create(:project) }
  end
end
