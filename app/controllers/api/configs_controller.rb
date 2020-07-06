module Api
  class ConfigsController < ApplicationController
    before_action :valid_session

    def project_data
      cities = CITIES.values.flatten
      data = {
        cities: cities,
        project_types: project_types.sort(&name),
        work_types: work_types,
        room_types: room_types
      }
      render json: data, status: :ok
    end

    private

    LookupTable::CATEGORIES.each do |category|
      define_method category.pluralize.to_sym do
        LookupTable.by_category(category).map do |type|
          { id: type.code, name: type.translation_spa, value: type.value }
        end
      end
    end
  end
end