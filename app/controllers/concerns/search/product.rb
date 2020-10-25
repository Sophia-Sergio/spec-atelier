
module Search
  module Product
    def product_sort
      if params[:sort].eql? 'created_at'
        product_list.order(created_at: :desc)
      else
        product_list.joins(:sections).order('sections.name, products.name')
      end
    end

    def product_list
      list.includes(:client, :brand, :subitems, :sections, :items)
    end

    def product_search_params
      %i[keyword brand project_type my_specifications room_type section item subitem]
    end
  end
end