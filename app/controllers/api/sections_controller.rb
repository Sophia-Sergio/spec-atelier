module Api
  class SectionsController < ApplicationController
    before_action :valid_session
    before_action :section, only: :products

    def index
      list = Section.all.order(:show_order).map do |section|
        { id: section.id, eng_name: section.eng_name, name: section.name }
      end
      render json: { sections: list }
    end

    def items
      items = section.items.as_json(only: %i[id name])
      render json: { section: section.name,  items: items }, status: :ok
    end

    def products
      list = section.products
      render json: { products: ::Products::ProductPresenter.decorate_list(list, params) }, status: :ok
    end

    private

    def section
      @section ||= Section.find(params[:id] || params[:section_id])
    end
  end
end
