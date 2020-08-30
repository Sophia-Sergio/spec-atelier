module Api
  class ProjectSpecsController < ApplicationController
    before_action :valid_session
    load_and_authorize_resource class: ProjectSpec::Specification, only: :show

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
      render json: { blocks: blocks }
    end

    def remove_text
      project_spec_text = project_specification.remove_text(params[:text])
      render json: { blocks: blocks }
    end

    def edit_text
      ProjectSpec::Text.find(params[:text]).update(text: params[:updated_text])
      render json: { blocks: blocks }
    end

    def create_product
      product = project_specification.create_product(project_spec_block_params, current_user)
      render json: { blocks: blocks }
    end

    def remove_product
      product = project_specification.remove_product(params[:block])
      render json: { blocks: blocks, message: 'Producto removido' }
    end

    def add_product_image
      image = Attached::Image.find(params[:image])
      project_specification.blocks.find(params[:block]).update(product_image_id: image.id)
      render json: { blocks: blocks, message: 'Imagen añadida' }
    end

    def remove_product_image
      project_specification.blocks.find(params[:block]).update(product_image_id: nil)
      render json: { blocks: blocks, message: 'Imagen removida' }
    end

    def reorder_blocks
      project_specification.reorder_blocks(params[:blocks])
      render json: { blocks: blocks, message: 'Orden Actualizado' }
    end

    def show
      render json: { blocks: blocks }
    end

    private

    def project_specification
      ProjectSpec::Specification.find(params[:id] || params[:project_spec_id])
    end

    def blocks
      ProjectSpec::SpecificationPresenter.decorate_list(project_specification.blocks.order(:order))
    end

    def project_spec_param
      params.require(:project_spec).permit(:section, :item, :subitem, :product, :order, :text_title, :text_description)
    end

    def project_spec_block_params
      params.permit(:text, :product, :block, :section, :item)
    end
  end
end
