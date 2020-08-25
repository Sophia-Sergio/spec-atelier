FactoryBot.define do
  factory :resource_file, class: 'Attached::ResourceFile' do
    owner { create(:product) }
    order { 0 }
    attached { create(:image) }

    trait :document do
      kind { 'product_document' }
    end

    trait :image do
      kind { 'product_image' }
    end
  end
end
