module Search
  module ProductFilters
    def filters(products, filters)
      { filters: accepted_filters(filters).each_with_object({}) {|f, h| h[f.pluralize] = send(f, products) } }
    end

    private

    def accepted_filters(filters)
      accepted_filters = %w[brand item subitem section project_type room_type specification]
      filters.select {|filter| accepted_filters.include? filter }
    end

    def project_type(products)
      lookup_table_data(products, 'room_type')
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
      types = products.pluck(category.to_sym).flatten.uniq
      LookupTable.by_category(category).where(code: types.map(&:to_i)).map do |lookup_table|
        { id: lookup_table.code, name: lookup_table.translation_spa }
      end
    end

    def relations(products, relation)
      products.map(&relation).flatten.uniq.map {|ele| { id: ele.id, name: ele.name } }
    end
  end
end
