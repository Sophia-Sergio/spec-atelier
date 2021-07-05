module Search
  module Handler
    extend ActiveSupport::Concern
    include Search::Project
    include Search::Product
    include Search::Client
    include Search::Brand
    include Search::Client
    include Search::User

    def filtered_list
      @list = try("#{class_name[:name]}_custom_list".to_sym) || list
      filter_params.each {|k, v| @list = list&.send("by_#{k}".to_sym, v) unless @list&.count&.zero? }
      @ordered = sorted_list.pluck(:id)
      sorted_list
    end

    def paginated_response(context = {})
      @list = filtered_list
      paginated_format({ user: current_user }.merge(context) )
    end

    def paginated_list(context)
      redis.del(redis_key) if @page == 0 && params[:view].present?
      @list = @list.where.not(id: without) if without.present?
      offset = without.present? ? (@limit * @page) - without.count : (@limit * @page)
      @list = @list.offset(offset).limit(@limit).find_ordered(@ordered)
      redis.lpush(redis_key, @list.pluck(:id).uniq) if params[:view].present?
      decorator.decorate_collection(@list, context: context)
    end

    def redis_key
      "products_user#{request.remote_ip}_#{params[:view]}"
    end

    def without
      redis.lrange(redis_key, 0, redis.llen(redis_key))
    end

    def decorator
      @decorator
    end

    def paginated_format(context)
      @page = params[:page].presence&.to_i || 0
      @offset = params[:offset].presence&.to_i || params[:limit].presence&.to_i || 10
      @limit = params[:limit].presence&.to_i || 10
      {
        total: @list.count,
        next_page: (@page + 1) * @limit < @list.count ? @page + 1 : nil,
        list: paginated_list(context)
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
      @sorted_list ||= send("#{class_name[:name]}_sort")
    end

    def filter_params
      params.slice(*send("#{class_name[:name]}_search_params")) rescue []
    end

    def class_name
      @class_name ||= begin
        name = params[:controller].sub('api/', '').singularize
        case name
        when 'brand' then { name: name, class: 'Brand'.constantize }
        else { name: name, class: name.capitalize.constantize }
        end
      end
    end
  end
end
