module Search
  module Handler
    extend ActiveSupport::Concern
    include Search::Project
    include Search::Product
    include Search::Brand

    def filtered_list
      filter_params.each {|k, v| @list = list&.send("by_#{k}".to_sym, v) unless @list&.count&.zero? }
      sorted_list
    end

    private

    def list
      @list ||= @custom_list || list_class.all
    end

    def custom_list
      @custom_list
    end

    def sorted_list
      send("#{class_name}_sort")
    end

    def list_class
      @list_class ||= class_name.capitalize.constantize
    end

    def filter_params
      params.slice(*send("#{class_name}_search_params"))
    end

    def class_name
      params[:controller].sub('api/', '').singularize
    end
  end
end