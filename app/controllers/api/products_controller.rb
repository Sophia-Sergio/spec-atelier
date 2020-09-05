module Api
  class ProductsController < ApplicationController
    include Search::Handler
    include AssociateFiles

    before_action :valid_session, except: :send_email
    before_action :product, only: %i[show]

    load_and_authorize_resource only: %i[update]


    def send_email
      EmailWorker.perform_async
      render json: { a: 'hola' }
    end

    def show
      render json: { product: decorator.decorate(product) }, status: :ok
    end

    def index
      @custom_list = Product.all.original
      render json: { products: paginated_response }, status: :ok
    end

    def create
      product = Product.new(product_params.except(:system_id, :brand).merge(user_id: current_user.id))
      product.subitem_id = product_params[:system_id] if product_params[:system_id].present?
      # Todo separare brand in client and brand, add validation only for client
      brand = Company::Brand.find_or_create_by(name: product_params[:brand])
      product.brand = brand if brand.valid?
      if product.save
        render json: { product: decorator.decorate(product) }, status: :created
      else
        render json: { error: product.errors }, status: :unprocessable_entity
      end
    end

    def update
      product.update(subitem_id: product_params[:system_id]) if product_params[:system_id].present?
      product.update(product_params.except(:system_id, :brand))

      render json: { product: decorator.decorate(product) }, status: :ok
    end

    def contact_form
      contact_form = product.contact_forms.create(contact_form_params.merge(user_id: current_user.id))
      ProductMailer.send_contact_form_to_brand(current_user, contact_form).deliver
      ProductMailer.send_contact_form_to_brand(current_user, contact_form).deliver
      render json: { form: contact_form, message: 'Mensaje enviado' }, status: :created
    end

    def associate_images
      associate_files(product, images_params[:images])
      render json: { message: 'Image attached'}, status: :created
    end

    def associate_documents
      associate_files(product, documents_params[:documents])
      render json: {}, status: :created
    end

    def remove_images
      product.files.where(attached_file_id: images_params[:images]).delete_all
      render json: { message: 'Images deleted'}, status: :created
    end

    def remove_documents
      product.files.where(attached_file_id: documents_params[:documents]).delete_all
      render json: { message: 'Documents deleted'}, status: :created
    end

    private

    def decorator
      @decorator ||= ProductDecorator
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
