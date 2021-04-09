FactoryBot.define do
  factory :spec_block, class: 'ProjectSpec::Block' do
    spec_item { create(:section) }
    project_spec { create(:spec_specification) }
    section { create(:section) }

    trait :product do
      spec_item { create(:product, :used_on_spec) }
      item { spec_item.items.first }
    end
  end
end
