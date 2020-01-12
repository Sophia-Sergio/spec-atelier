module Api
  class UsersController < ApplicationController
    before_action :valid_session
    before_action :set_user
    load_and_authorize_resource

    def update
      @user.update(user_params)
      render json: { user: BasicUserPresenter.decorate(@user) }, status: :ok
    end

    def show
      render json: { user: BasicUserPresenter.decorate(@user) }, status: :ok
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e }, status: :not_found
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :birthday, :office)
    end
  end
end
