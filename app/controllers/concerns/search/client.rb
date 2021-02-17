module Search
  module Client
    def client_sort
      list.order(:name)
    end

    def client_search_params
      %i[keyword]
    end
  end
end
