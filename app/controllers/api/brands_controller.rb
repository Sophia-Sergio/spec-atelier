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
      contact_form = brand.contact_forms.create(contact_form_params.merge(user_id: current_user.id))
      product = product.contact_forms.create(contact_form_params.merge(user_id: current_user.id))
      BrandMailer.send_contact_form_to_brand(current_user, contact_form, product).deliver
      BrandMailer.send_contact_form_to_user(current_user, contact_form, product).deliver
      render json: { form: contact_form, product: product, message: 'Mensaje enviado' }, status: :created
    end

    private

    def brand
      Company::Brand.find(params[:id] || params[:brand_id])
    end

    def presenter
      Brands::BrandPresenter
    end

    def contact_form_params
      params.require(:brand_contact_form).permit(:user_phone, :message)
    end
  end
end
