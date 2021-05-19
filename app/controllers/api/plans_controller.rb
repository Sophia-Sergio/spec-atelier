module Api
  class PlansController < ApplicationController

    def contact_form
      plan_contact_form = PlanContactForm.new(contact_form_params)
      if plan_contact_form.save
        PlanMailer.send_contact_form_to_client(plan_contact_form).deliver_later
        PlanMailer.send_contact_form_to_spec(plan_contact_form).deliver_later
        render json: { form: plan_contact_form, message: 'Mensaje enviado' }, status: :created
      else
        render json: { message: 'Mensaje falló' }, status: :unprocessable_entity
      end
    end

    def contact_form_params
      params.require(:plan_contact_form).permit(:plan_type, :user_name, :items_total, :phone, :email, :message)
    end
  end
end
