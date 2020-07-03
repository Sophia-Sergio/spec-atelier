
module Search
  module Product
    def product_sort
      if params[:sort].eql? 'created_at'
        product_list.order(created_at: :desc)
      else
        product_list.joins(:section).order('sections.name, products.name')
      end
    end

    def product_list
      list.includes(:item, :subitem, :brand, files: :attached)
    end

    def product_search_params
      %i[keyword brand project_type my_specifications room_type section item]
    end
  end
end