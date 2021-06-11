module Search
  module User
    def user_sort
      list.order(:last_name)
    end

    def user_search_params
      %i[keyword]
    end
  end
end
