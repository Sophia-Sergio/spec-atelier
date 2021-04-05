module Api
  class SectionsController < ApplicationController
    include Search::Handler

    before_action :valid_session, except: :index
    before_action :section, only: :products

    def index
      list = Section.all
      list = list.with_products if params[:with_products]
      render json: { sections: SectionDecorator.decorate_collection(list.order(:show_order)) }
    end

    def items
      items = section.items.as_json(only: %i[id name])
      render json: { section: section.name, items: items }, status: :ok
    end

    def products
      @custom_list = section.products
      @decorator = Products::ProductDecorator
      @class_name = { name: 'product', class: Product }
      render json: { products: paginated_response }, status: :ok
    end

    private

    def section
      @section ||= Section.find(params[:id] || params[:section_id])
    end
  end
end
