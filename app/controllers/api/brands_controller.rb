module Api
  class BrandsController < ApplicationController
    before_action :valid_session

    def index
      list = Brand.all.includes(:products)
      list = list.map {|brand| { id: brand.id, name: brand.name } }
      render json: { brands: list }, status: :ok
    end

    def search
      list = Brand.search(params[:query]).limit(10)
      list = list.map {|brand| { id: brand.id, name: brand.name } }
      render json: { brands: list }, status: :ok
    end
  end
end
