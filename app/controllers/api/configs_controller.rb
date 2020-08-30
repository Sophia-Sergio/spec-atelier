module Api
  class ConfigsController < ApplicationController
    before_action :valid_session

    def project_data
      cities = CITIES.values.flatten
      data = {
        cities: cities,
        project_types: project_types.sort_by {|a| a[:name] },
        work_types: work_types.sort_by {|a| a[:name] },
        room_types: room_types.sort_by {|a| a[:name] }
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
      { id: type.code, name: type.translation_spa, value: type.value }
    end
  end
end