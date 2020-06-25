module Api
  class ProjectsController < ApplicationController
    include Search::Handler
    before_action :valid_session
    before_action :project, only: %i[show edit delete]
    before_action :projects, only: %i[index search]

    def index
      @custom_list = current_user.projects
      render json: { projects: presenter.decorate_list(filtered_list, params) }, status: :ok
    end

    def show
      render json: { project: presenter.decorate(project) }, status: :ok
    end

    def create
      project = Project.new(project_params.merge(user: current_user))
      project.country = 'Chile'
      if project.save
        render json: { project: presenter.decorate(project) }, status: :created
      else
        render json: { error: project.errors }, status: :unprocessable_entity
      end
    end

    def update
      project.update(project_params)
      render json: { project: presenter.decorate(project) }, status: :ok
    end

    def destroy
      project.update(soft_deleted: true)
      render json: '', status: :no_content
    end

    def ordered
      projects_list = projects.order(formated_ordered_param)
      render json: { projects: private_project_presenter.decorate_list(projects_list) }, status: :created
    end

    private

    def project
      @project ||= Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:name, :project_type, :work_type, :country, :city, :delivery_date, :visibility)
    end

    def projects
      @projects ||= current_user.projects
    end

    def presenter
      Projects::PrivateProjectPresenter
    end
  end
end
