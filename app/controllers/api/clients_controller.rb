module Api
  class ClientsController < ApplicationController
    include Search::Handler
    before_action :valid_session, except: %i[index show]

    def index
      @custom_list = with_products? ? clients_with_products : Client.all
      render json: { clients: paginated_response }, status: :ok
    end

    def show
      render json: { client: decorator.decorate(client) }, status: :ok
    end

    def contact_form
      if client.default_email.present?
        contact_form = client.contact_forms.create(contact_form_params.merge(user_id: current_user.id))
        ClientMailer.send_contact_form_to_client(current_user, contact_form).deliver_later
        ClientMailer.send_contact_form_to_user(current_user, contact_form).deliver_later
        render json: { form: contact_form, message: 'Mensaje enviado' }, status: :created
      else
        render json: { message: 'Mensaje NO fue enviado, marca no tiene email' }, status: :not_acceptable
      end
    end

    private

    def client
      Client.find(params[:id] || params[:client_id])
    end

    def decorator
      ClientDecorator
    end

    def contact_form_params
      params.require(:client_contact_form).permit(:user_phone, :message)
    end

    def with_products?
      params[:section].present? || params[:item].present?
    end

    def clients_with_products
      scope = Client.all
      if params[:section].present?
        scope = scope.joins(products: :items).where({ items: { section_id: params[:section] } })
      end
      scope = scope.joins(products: :items).where(items: { id: params[:item] }) if params[:item].present?
      Client.where(id: scope.select(:id))
    end
  end
end
