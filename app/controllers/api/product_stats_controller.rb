module Api
  class ProductStatsController < ApplicationController
    before_action :product_stat
    authorize_resource class: ProductStat

    def update_downloads
      product_stat.increment!(params[:stat])
      render json: {}, response: :success
    end

    private

    def product_stat
      @product_stat ||= ProductStat.find_by(product_id: params[:product_id])
    end
  end
end
