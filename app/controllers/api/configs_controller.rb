module Api
  class ConfigsController < ApplicationController

    def project_data
      cities = CITIES.values.flatten
      @project_types = project_types
      data = {
        cities: cities.sort,
        project_types: @project_types.sort_by {|a| I18n.transliterate(a[:name]) },
        work_types: work_types.sort_by {|a| I18n.transliterate(a[:name]) },
        room_types: room_types.map do |room_type|
          hash = @project_types.select {|a| room_type[:related_category_codes].include? a[:id].to_s }
          room_type.merge(project_types: hash )
        end.sort_by {|a| I18n.transliterate(a[:name].capitalize) }
      }
      render json: data, status: :ok
    end

    def room_types_by_project_type
      list = LookupTable.by_category('room_type').by_project_type(params[:project_types])
      render json: { room_types: list.map {|type| lookup_table_format(type) } }
    end

    private

    LookupTable::CATEGORIES.each do |category|
      define_method category.pluralize.to_sym do
        LookupTable.by_category(category).map {|type| lookup_table_format(type) }
      end
    end

    def lookup_table_format(type)
      {
        id: type.code,
        name: type.translation_spa.capitalize,
        value: type.value,
        related_category: type.related_category,
        related_category_codes: type.related_category_codes
      }
    end
  end
end