FactoryBot.define do
  factory :brand do
    sequence(:name) {|n| "fake brand #{n}" }
    phone { { main: Faker::PhoneNumber.cell_phone } }
    email { { main: Faker::Internet.email } }
    address { Faker::Address.full_address }
    social_media { { facebook: 'https://www.facebook.com/brand', instagram: 'https://www.instagram.com/brand' } }
    web { 'https://www.brand.com' }
    description { Faker::Lorem.paragraph }
    country { 'Chile' }
  end
end
