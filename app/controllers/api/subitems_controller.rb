module Api
  class SubitemsController < ApplicationController
    before_action :valid_session, except: :index

    def index
      list = Subitem.all
      list = list.where(item_id: params[:item]) if params[:item].present?
      list = list.order(:name).map {|item| { id: item.id, name: item.name } }
      render json: { subitems: list }
    end
  end
end
