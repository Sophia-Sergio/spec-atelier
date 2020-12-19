FactoryBot.define do
  factory :product_contact_form, class: 'Form::ProductContactForm' do
    owner { create(:product) }
    user { create(:user) }
    message { 'Soy un mensaje' }
  end
end
