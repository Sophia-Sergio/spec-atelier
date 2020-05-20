module Api
  class ProjectSpecsController < ApplicationController
    before_action :valid_session

    def create
      ProjectSpec.create(project_spec_param)
      render json: '', status: :created
    end

    def update
      project.update(project_spec_param)
      render json: '', status: :ok
    end

    def create_text
      project_spec_text = project_specification.create_text(params[:text], params[:section_id], params[:item_id])
      render json: { text:
        { id: project_spec_text.id, text: project_spec_text.text, spec_item_id: project_spec_text.item.id }
      }
    end

    private

    def project_specification
      ProjectSpec::Specification.find(params[:id] || params[:project_spec_id])
    end

    def project_spec_param
      params.require(:project_spec).permit(:section, :item, :subitem, :product, :order, :text_title, :text_description)
    end
  end
end
