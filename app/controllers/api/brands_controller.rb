module Api
  class BrandsController < ApplicationController
    include Search::Handler
    before_action :valid_session, except: %i[index show]
    load_and_authorize_resource

    def index
      @custom_list = with_products? ? brands_with_products : @brands
      render json: { brands: paginated_response }, status: :ok
    end

    private

    def brand
      Brand.find(params[:id] || params[:brand_id])
    end

    def decorator
      BrandDecorator
    end

    def contact_form_params
      params.require(:brand_contact_form).permit(:user_phone, :message)
    end

    def with_products?
      params[:section].present? || params[:item].present? || params[:with_products]
    end

    def brands_with_products
      scope = @brands
      scope = scope.joins(products: :items).where(items: { section_id: params[:section] }) if params[:section].present?
      scope = scope.joins(products: :items).where(items: { id: params[:item] }) if params[:item].present?
      @brands.where(id: scope.select(:id))
    end
  end
end
