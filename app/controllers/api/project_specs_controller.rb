module Api
  class ProjectSpecsController < ApplicationController
    include AssociateFiles

    before_action :valid_session, except: :download_word
    before_action :touch_project, only: %i[
      create_text remove_text edit_text create_product remove_block add_product_image remove_product_image
    ]
    load_and_authorize_resource class: ProjectSpec::Specification, only: [:show, :reorder_blocks]

    def create
      ProjectSpec.create(project_spec_param)
      render json: '', status: :created
    end

    def update
      project.update(project_spec_param)
      render json: '', status: :ok
    end

    def create_text
      project_specification.create_text(project_spec_block_params)
      render json: { blocks: blocks }
    end

    def remove_text
      project_specification.remove_text(params[:text])
      render json: { blocks: blocks }
    end

    def edit_text
      ProjectSpec::Text.find(params[:text]).update(text: params[:updated_text])
      render json: { blocks: blocks }
    end

    def create_product
      product = Product.find(params[:product])
      ::Products::ProductSpecCreator.call(
        project_spec_block_params, nil, product, project_spec: project_specification
      )
      render json: { blocks: blocks }
    end

    def remove_block
      project_specification.remove_block(params[:block])
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
      ProjectSpec::BlocksUserReorder.call(@project_spec, params[:blocks])
      render json: { blocks: blocks, message: 'Orden Actualizado' }
    end

    def show
      render json: { blocks: blocks, project: { id: @project_spec.project.id, name: @project_spec.project.name } }
    end

    def download_word
      uploaded_file = SpecificationGenerator.new(project_specification).generate
      render json: { url: uploaded_file }, status: :ok
    end

    def download_budget
      excel = ProjectSpec::BudgetCreation.new(project_specification).generate
      send_data(excel, filename: 'presupuesto.xls')
    end

    def my_specifications
      list = current_user.specifications.includes(:project)
      list = list.with_products if params[:with_products]
      list = list.map {|specification| { id: specification.id, name: specification.project.name } }
      render json: { specifications: list }
    end

    private

    def touch_project
      project_specification.touch
    end

    def project_specification
      ProjectSpec::Specification.find(params[:id] || params[:project_spec_id])
    end

    def blocks
      project_spec = @project_spec || project_specification
      blocks = project_spec.blocks.preload(
        :section, :item, :product, :spec_item, :text, product: %i[sections subitems brand client files]
      ).order(:order)
      ProjectSpecDecorator.decorate_collection(blocks)
    end

    def project_spec_param
      params.require(:project_spec).permit(:section, :item, :subitem, :product, :order, :text_title, :text_description)
    end

    def project_spec_block_params
      params.permit(:text, :product, :block, :section, :item, item: [])
    end
  end
end
