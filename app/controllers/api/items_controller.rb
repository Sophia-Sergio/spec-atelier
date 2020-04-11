module Api
  class ItemsController < ApplicationController
    before_action :valid_session
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

    private

    def item
      @item ||= Item.find(params[:item_id])
    end
  end
end
