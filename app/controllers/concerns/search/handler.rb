module Search
  module Handler
    extend ActiveSupport::Concern
    include Search::Project
    include Search::Product
    include Search::Brand

    def filtered_list
      filter_params.each {|k, v| @list = list&.send("by_#{k}".to_sym, v) unless @list&.count&.zero? }
      @ordered = sorted_list.pluck(:id)
      sorted_list
    end

    def paginated_response
      @list = filtered_list
      paginated_format
    end

    def list
      @custom_list
    end

    def paginated_list
      @page = params[:page].presence&.to_i || 0
      @offset = params[:offset].presence&.to_i || params[:limit].presence&.to_i || 10
      @limit = params[:limit].presence&.to_i || 10
      decorator.decorate_collection(@list.offset(@limit * @page).limit(@limit).find_ordered(@ordered))
    end

    def paginated_format
      {
        total:     @list.count,
        list:      paginated_list,
        next_page: (@page + 1) * @limit < @list.count ? @page + 1 : nil
      }
    end

    private

    def list
      @list ||= custom_list || class_name[:class].all
    end

    def custom_list
      @custom_list
    end

    def sorted_list
      send("#{class_name[:name]}_sort")
    end

    def filter_params
      params.slice(*send("#{class_name[:name]}_search_params"))
    end

    def class_name
      name = params[:controller].sub('api/', '').singularize
      case name
      when 'brand' then { name: name, class: 'Company::Brand'.constantize }
      else { name: name, class: name.capitalize.constantize }
      end
    end
  end
end