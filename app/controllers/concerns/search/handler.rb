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