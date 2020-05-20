module Api
  class ConfigsController < ApplicationController
    before_action :valid_session

    def project_data
      cities = CITIES.values.flatten
      data = {
        cities: cities,
        project_types: project_types.map {|project_type| { id: project_type.code, name: project_type.translation_spa } },
        work_types: work_types,
        room_types: room_types
      }
      render json: data, status: :ok
    end

    private

    LookupTable::CATEGORIES.each do |category|
      define_method category.pluralize.to_sym do
        LookupTable.by_category(category)
      end
    end
  end
end