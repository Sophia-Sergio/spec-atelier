module Search
  module ProductFilters
    def filters(products, params)
      @params = params
      filters = params[:filters]
      { filters: accepted_filters(filters).each_with_object({}) {|f, h| h[f.pluralize] = send(f, products) } }
    end

    private

    def accepted_filters(filters)
      accepted_filters = %w[brand item subitem section project_type room_type specification]
      filters.select {|filter| accepted_filters.include? filter }
    end

    def project_type(products)
      lookup_table_data(products, 'project_type')
    end

    def room_type(products)
      lookup_table_data(products, 'room_type')
    end

    def brand(products)
      brand_ids = products.pluck(:brand_id)
      ::Brand.where(id: brand_ids).map {|brand| { id: brand.id, name: brand.name } }
    end

    def item(products)
      relations(products, :items)
    end

    def subitem(products)
      relations(products, :subitems)
    end

    def section(products)
      relations(products, :sections)
    end

    def specification(products)
      ProjectSpec::Specification.by_user(current_user).by_product(products)
    end

    def lookup_table_data(products, category)
      types = products.pluck(category.to_sym).flatten.uniq.map(&:to_i)
      list = LookupTable.by_category(category).where(code: types).order(:translation_spa)
      list = list.select {|e| @params[:project_type].include? e.code.to_s } if project_type_select?(category)
      list = list.select {|e| @params[:room_type].include? e.code.to_s } if room_type_select?(category)
      list = list.select {|e| (e.related_category_codes & @params[:project_type]).any? } if category == 'room_type'
      list.map {|lookup_table| { id: lookup_table.code, name: lookup_table.translation_spa.capitalize } }
          .sort_by {|lookup_table| I18n.transliterate(lookup_table[:name]) }
    end

    def project_type_select?(category)
      @params[category.to_sym].present? && category == 'project_type'
    end

    def room_type_select?(category)
      @params[category.to_sym].present? && category == 'room_type'
    end

    def relations(products, relation)
      products.map(&relation).flatten.uniq.map {|ele| { id: ele.id, name: ele.name } }
    end
  end
end
