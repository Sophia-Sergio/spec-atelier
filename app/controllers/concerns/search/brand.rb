module Search
  module Brand
    def brand_sort
      list.order(:name)
    end

    def brand_search_params
      %i[keyword]
    end
  end
end
