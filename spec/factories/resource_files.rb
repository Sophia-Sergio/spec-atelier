FactoryBot.define do
  factory :resource_file, class: 'Attached::ResourceFile' do
    owner { create(:product) }
    order { 0 }
    attached { create(:image) }
  end
end
