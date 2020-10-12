module Api
  class ItemsController < ApplicationController
    before_action :valid_session, except: :index
    before_action :item, only: :products

    def products
      list = item.products.includes(:subitem)
      decorated_list = ::Products::ProductPresenter.decorate_list(list, params)
      render json: { products: decorated_list }
    end

    def subitems # systems on the UI
      list = item.subitems.map {|subitem| { id: subitem.id, name: subitem.name } }
      render json: { systems: list }
    end

    def index
      list = Item.all
      list = list.where(section_id: params[:section]) if params[:section].present?
      list = list.order(:name).map {|item| { id: item.id, name: item.name} }
      render json: { items: list }
    end

    private

    def item
      @item ||= Item.find(params[:item_id])
    end
  end
end
