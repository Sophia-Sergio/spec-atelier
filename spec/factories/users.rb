FactoryBot.define do
  factory :user do
    email    { Faker::Internet.email }
    password { '123456' }
    first_name { 'fake first name' }
    last_name  { 'fake last name' }

    trait :with_password_token do
      reset_password_token { 'token' }
      reset_password_sent_at { Time.zone.now }
    end

    trait :superadmin do
      roles { [create(:role, name: 'superadmin')]}
    end
  end
end
