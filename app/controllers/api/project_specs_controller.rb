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
      project_spec_text = project_specification.create_text(project_spec_block_params)
      render json: { text: {
                             id: project_spec_text.id,
                             text: project_spec_text.text,
                             block_related: project_spec_text.block_item.as_json
                           }
      }
    end

    def create_product
      product = project_specification.create_product(project_spec_block_params)
      render json: { product: product }
    end

    def show
      blocks = ProjectSpec::SpecificationPresenter.decorate_list(project_specification.blocks.order(:order))
      render json: { blocks: blocks }
    end

    private

    def project_specification
      ProjectSpec::Specification.find(params[:id] || params[:project_spec_id])
    end

    def project_spec_param
      params.require(:project_spec).permit(:section, :item, :subitem, :product, :order, :text_title, :text_description)
    end

    def project_spec_block_params
      params.permit(:text, :product, :block, :section, :item)
    end
  end
end
