module Api
  class ProductsController < ApplicationController
    include Search::Handler

    before_action :valid_session
    before_action :product, only: %i[show]

    load_and_authorize_resource only: %i[update]

    def show
      render json: { product: presenter.decorate(product) }, status: :ok
    end

    def index
      render json: { products: presenter.decorate_list(filtered_list, params) }, status: :ok
    end

    def create
      product = Product.new(product_params.except(:system_id, :brand).merge(user_id: current_user.id))
      product.subitem_id = product_params[:system_id] if product_params[:system_id].present?
      # Todo separare brand in client and brand, add validation only for client
      brand = Company::Brand.find_or_create_by(
        name: product_params[:brand],
        url: 'default',
        contact_info: 'default',
        email: 'default',
        description: 'default'
      )
      product.brand = brand if brand.valid?
      if product.save
        render json: { product: presenter.decorate(product) }, status: :created
      else
        render json: { error: product.errors }, status: :unprocessable_entity
      end
    end

    def update
      product.update(subitem_id: product_params[:system_id]) if product_params[:system_id].present?
      product.update(product_params.except(:system_id, :brand))

      render json: { product: presenter.decorate(product) }, status: :ok
    end

    def contact_form
      contact_form = product.contact_forms.create(contact_form_params.merge(user_id: current_user.id))
      ProductMailer.send_contact_form_to_brand(current_user, contact_form).deliver
      ProductMailer.send_contact_form_to_brand(current_user, contact_form).deliver
      render json: { form: contact_form, message: 'Mensaje enviado' }, status: :created
    end

    def associate_images
      GoogleStorage.new(product, images_params[:images]).perform
      render json: { message: 'Image attached'}, status: :created
    end

    def associate_documents
      GoogleStorage.new(product, documents_params[:documents]).perform
      render json: {}, status: :created
    end

    private

    def presenter
      ::Products::ProductPresenter
    end

    def product
      @product ||= Product.find(params[:id] || params[:product_id])
    end

    def images_params
      params.permit({ images: [] })
    end

    def documents_params
      params.permit({ documents: [] })
    end

    def product_params
      permitted = %i[name item_id system_id brand long_desc short_desc price project_type work_type room_type product_id]
      params.require(:product).permit(permitted)
    end

    def contact_form_params
      params.require(:product_contact_form).permit(:user_phone, :message)
    end
  end
end
