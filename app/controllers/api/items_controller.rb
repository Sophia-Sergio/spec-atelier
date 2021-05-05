module Api
  class ItemsController < ApplicationController
    before_action :valid_session, except: :index
    before_action :item, only: :products

    def subitems # systems on the UI
      list = item.subitems.map {|subitem| { id: subitem.id, name: subitem.name } }
      render json: { systems: list }
    end

    def index
      list = Item.all.order(:show_order)
      list = list.where(section: params[:section]) if params[:section].present?
      list = list.with_products if params[:with_products]
      render json: { items: ItemDecorator.decorate_collection(list, context: { user: user }) }
    end

    private

    def item
      @item ||= Item.find(params[:item_id])
    end
  end
end
