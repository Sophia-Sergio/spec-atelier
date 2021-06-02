module Api
  class ProjectConfigsController < ApplicationController
    before_action :valid_session

    def create
      config = Project.find(params[:project_id]).config
      config.update!(project_config_params)
      render json: { project_config: config.as_json(except: %i[created_at updated_at id])}
    end

    private

    def project_config_params
      params.require(:project_config).permit(
        visible_attrs: { product: %i[default brand long_desc short_desc reference] }
      )
    end
  end
end
