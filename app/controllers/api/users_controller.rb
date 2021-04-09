module Api
  class UsersController < ApplicationController
    before_action :valid_session
    before_action :set_user
    load_and_authorize_resource

    def update
      user = Users::UserUpdater.new(@user, user_params).call
      render json: { user: UserDecorator.decorate(user) }, status: :ok
    end

    def profile_image_upload
      Users::UserProfileImageUpdater.new(@user, params[:image]).call
      render json: { user: UserDecorator.decorate(@user) }, status: :ok
    end

    def show
      render json: { user: UserDecorator.decorate(@user) }, status: :ok
    end

    def stats
      stats = Users::UserStats.new(
        current_user,
        params: stat_params,
        project: Project.find(stat_params[:project]),
        product: Product.find(stat_params[:product])
      ).send(stat_params[:stat])
      render json: stats, status: :ok
    end

    private

    def set_user
      @user = User.find(params[:id] || params[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e }, status: :not_found
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :birthday, :company, :city)
    end

    def stat_params
      params.permit(:limit, :sort_by, :sort_order, :stat, :project, :product)
    end
  end
end
