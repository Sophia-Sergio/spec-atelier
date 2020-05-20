module Api
  class ProductsController < ApplicationController
    include ProductsSearch

    before_action :valid_session
    before_action :product, only: %i[show]

    def show
      render json: { product: ::Products::ProductPresenter.decorate(product) }, status: :ok
    end

    def index
      render json: { products: ::Products::ProductPresenter.decorate_list(products_filtered, params) }, status: :ok
    end

    def create
      product = Product.new(product_params.except(:system_id, :brand))
      product.subitem_id = product_params[:system_id] if product_params[:system_id].present?
      brand = Brand.find_or_create_by(name: product_params[:brand])
      product.brand = brand if brand.valid?
      if product.save
        render json: { product: ::Products::ProductPresenter.decorate(product) }, status: :created
      else
        render json: { error: product.errors }, status: :unprocessable_entity
      end
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
  end
end
