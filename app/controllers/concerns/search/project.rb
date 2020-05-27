
module Search
  module Project
    def project_sort
      if params[:sort].present?
        column = params[:sort].sub(/_asc|_desc/, '').to_sym
        order  = params[:sort].split('_').last
        sort = { column => order }
        list.order(sort)
      else
        list.order(created_at: :desc)
      end
    end

    def project_search_params
      %i[keyword]
    end
  end
end