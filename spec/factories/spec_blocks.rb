FactoryBot.define do
  factory :spec_block, class: 'ProjectSpec::Block' do
    spec_item { create(:section) }
    project_spec { create(:project_spec) }
  end
end
