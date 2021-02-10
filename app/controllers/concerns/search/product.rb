module Search
  module Product
    def product_sort
      case true
      when params[:sort].eql?('created_at') then product_list.order(created_at: :desc)
      when params[:most_used] == 'true' then product_list.most_used
      else product_list.joins(:sections).order('sections.name, products.name')
      end
    end

    def product_list
      list.includes(:client, :brand, :subitems, :sections, :items, :product_items, :product_subitems)
    end

    def product_search_params
      %i[keyword brand project_type specification room_type section item subitem]
    end

    def product_custom_list
      product_custom_list = custom_list
      product_custom_list = my_products(product_custom_list) if params[:my_products] == 'true'
      product_custom_list
    end

    private

    def my_products(product_custom_list)
      product_custom_list.by_user(current_user)
    end
  end
end
