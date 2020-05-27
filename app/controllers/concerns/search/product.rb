
module Search
  module Product
    def product_sort
      if params[:sort].eql? 'created_at'
        list.order(created_at: :desc)
      else
        list.joins(:section).order('sections.name')
      end
    end

    def products_search_params
      %i[keyword brand project_type my_specifications room_type section item]
    end
  end
end