module Api
  class BrandsController < ApplicationController
    include Search::Handler
    before_action :valid_session

    def index
      decorated_list = presenter.decorate_list(filtered_list.includes(:products), params)
      render json: { brands: decorated_list }, status: :ok
    end

    def show
      render json: { brand: presenter.decorate(brand) }, status: :ok
    end

    def contact_form
      contact_form = brand.brand_contact_forms.create(contact_form_params.merge(user_id: current_user.id))
      BrandMailer.send_contact_form(current_user, contact_form).deliver
      render json: { brand: contact_form, message: 'Mensaje enviado'}, status: :created
    end

    private

    def brand
      Brand.find(params[:id] || params[:brand_id])
    end

    def presenter
      Brands::BrandPresenter
    end

    def contact_form_params
      params.permit(:user_phone, :message)
    end
  end
end
