module Api
  class ProductsController < ApplicationController
    include Search::Handler
    include Search::ProductFilters
    include AssociateFiles

    before_action :valid_session, except: %i[index show]
    load_and_authorize_resource except: %i[create index]

    def show
      @product.stats.increment!(:visualizations) if @product.original?
      render json: { product: decorator.decorate(@product) }, status: :ok
    end

    def index
      @custom_list = products
      list = paginated_response(project_spec: params[:project_spec])
      filters = params[:filters].present? ? filters(@list, params) : {}
      render json: { products: list.merge(filters) }, status: :ok
    end

    def create
      product = ::Products::ProductCreator.new(product_params, current_user).call
      render json: { product: decorator.decorate(product) }, status: :created if product.present?
    end

    def destroy
      @product.destroy!
      render json: { product: decorator.decorate(@product) }, status: :ok
    end

    def update
      updated_product = ::Products::ProductUpdater.new(product_params, nil, @product).call
      render json: { product: decorator.decorate(updated_product) }, status: :ok
    end

    def contact_form
      contact_form = @product.contact_forms.create(contact_form_params.merge(user_id: current_user.id))
      ProductMailer.send_contact_form_to_client(current_user, contact_form).deliver_later
      ProductMailer.send_contact_form_to_user(current_user, contact_form).deliver_later
      render json: { form: contact_form, message: 'Mensaje enviado' }, status: :created
    end

    def associate_images
      associate_files(@product, images_params[:images], 'image')
      render json: { message: 'Image attached' }, status: :created
    end

    def associate_documents
      associate_files(@product, documents_params[:documents], 'document')
      render json: {}, status: :created
    end

    def remove_images
      @product.files.where(attached_file_id: images_params[:images]).delete_all
      render json: { message: 'Images deleted'}, status: :created
    end

    def remove_documents
      @product.files.where(attached_file_id: documents_params[:documents]).delete_all
      render json: { message: 'Documents deleted'}, status: :created
    end

    private

    def decorator
      @decorator ||= Products::ProductDecorator
    end

    def products
      @products ||= if params[:client_products].present?
        Product.accessible_by(current_ability, :client_products)
      else
        Product.accessible_by(current_ability)
      end
    end

    def images_params
      params.permit({ images: [] })
    end

    def documents_params
      params.permit({ documents: [] })
    end

    def product_params
      permitted = %i[name item system brand long_desc short_desc price project_type work_type room_type product_id reference unit]
      params.require(:product).permit(permitted + [item: [], system: []])
    end

    def contact_form_params
      params.require(:product_contact_form).permit(:user_phone, :message)
    end
  end
end
