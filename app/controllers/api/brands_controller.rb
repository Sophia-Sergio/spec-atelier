module Api
  class BrandsController < ApplicationController
    include Search::Handler
    before_action :valid_session, except: %i[index]

    def index
      @custom_list = with_products? ? brands_with_products : Client.all
      render json: { brands: paginated_response }, status: :ok
    end

    def show
      render json: { brand: decorator.decorate(brand) }, status: :ok
    end

    def contact_form
      if brand.default_email.present?
        contact_form = brand.contact_forms.create(contact_form_params.merge(user_id: current_user.id))
        ClientMailer.send_contact_form_to_client(current_user, contact_form).deliver_later
        ClientMailer.send_contact_form_to_user(current_user, contact_form).deliver_later
        render json: { form: contact_form, message: 'Mensaje enviado' }, status: :created
      else
        render json: { message: 'Mensaje NO fue enviado, marca no tiene email' }, status: :not_acceptable
      end
    end

    private

    def brand
      Client.find(params[:id] || params[:brand_id])
    end

    def decorator
      BrandDecorator
    end

    def contact_form_params
      params.require(:brand_contact_form).permit(:user_phone, :message)
    end

    def with_products?
      params[:section].present? || params[:item].present?
    end

    def brands_with_products
      scope = Client.all
      if params[:section].present?
        scope = scope.joins(products: :item).where(products: {items: { section_id:  params[:section]}})
      end
      scope = scope.joins(:products).where(products: {item_id:  params[:item]}) if params[:item].present?
      Client.where(id: scope.select(:id))
    end
  end
end
