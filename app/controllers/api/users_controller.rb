module Api
  class UsersController < ApplicationController
    include Search::Handler

    before_action :valid_session
    before_action :set_user, except: %i[index impersonate]
    load_and_authorize_resource except: %i[index impersonate]
    authorize_resource only: %i[index impersonate]

    def index
      @custom_list = User.all.where.not(id: current_user&.id)
      render json: { users: paginated_response }
    end

    def impersonate
      user_impersonate = User.find_by(id: params[:user_id])
      Users::UserImpersonate.call(user_impersonate)
      render json: { user: UserDecorator.decorate(user_impersonate) }
    end

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
        project: Project.find_by(id: stat_params[:project].presence),
        product: Product.find_by(id: stat_params[:product].presence)
      ).send(stat_params[:stat])
      render json: stats, status: :ok
    end

    private

    def set_user
      @user = User.find(params[:id] || params[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e }, status: :not_found
    end

    def decorator
      UserDecorator
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :birthday, :company, :city)
    end

    def stat_params
      params.permit(:page, :limit, :sort_by, :sort_order, :stat, :project, :product)
    end
  end
end
