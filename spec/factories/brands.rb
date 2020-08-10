FactoryBot.define do
  factory :brand, class: 'Company::Brand' do
    sequence(:name) {|n| "fake brand #{n}" }
    phone { { main: Faker::PhoneNumber.cell_phone } }
    email { { main: Faker::Internet.email } }
    social_media { { facebook: 'https://www.facebook.com/brand', instagram: 'https://www.instagram.com/brand' } }
    url { 'https://www.brand.com' }
    description { Faker::Lorem.paragraph }
    contact_info { 'Oficina Central' }
  end
end
