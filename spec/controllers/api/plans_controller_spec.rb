require 'rails_helper'
describe Api::PlansController, type: :controller do

  describe '#contact_form' do
    before do
      @params = {
          plan_contact_form: {
          plan_type: 'fijo',
          items_total: 2,
          user_name: 'Bertrand Russell',
          user_company_name: 'Compañía',
          email: 'brusell@gmail.com',
          phone: '+56 9 99944656',
          message: 'i want a plan'
        }
      }
    end

    context 'con todos los parámetros correctos' do
      it 'should send an email and an a success response' do
        post :contact_form, params: @params
        expect(response).to have_http_status(:created)
        expect(ActionMailer::Base.deliveries.count).to eq 2
        expect(PlanContactForm.find_by(user_company_name: 'Compañía', user_name: 'Bertrand Russell').present?).to be true
      end
    end

    context 'con algún parámetro incorrectos' do
      it 'should send an email and an a success response' do
        post :contact_form, params: @params.deep_merge(plan_contact_form: { plan_type: 'random plan' })
        expect(response).to have_http_status(:unprocessable_entity)
        expect(ActionMailer::Base.deliveries.count).to eq 0
      end
    end
  end
end
