module Api
  class BrandsController < ApplicationController
    include Search::Handler
    before_action :valid_session, except: %i[index]

    def index
      @custom_list = Company::Client.all
      render json: { brands: paginated_response }, status: :ok
    end

    def show
      render json: { brand: decorator.decorate(brand) }, status: :ok
    end

    def contact_form
      if brand.default_email.present?
        contact_form = brand.contact_forms.create(contact_form_params.merge(user_id: current_user.id))
        BrandMailer.send_contact_form_to_brand(current_user, contact_form).deliver_later
        BrandMailer.send_contact_form_to_user(current_user, contact_form).deliver_later
        render json: { form: contact_form, message: 'Mensaje enviado' }, status: :created
      else
        render json: { message: 'Mensaje NO fue enviado, marca no tiene email' }, status: :not_acceptable
      end
    end

    private

    def brand
      Company::Client.find(params[:id] || params[:brand_id])
    end

    def decorator
      BrandDecorator
    end

    def contact_form_params
      params.require(:brand_contact_form).permit(:user_phone, :message)
    end
  end
end
