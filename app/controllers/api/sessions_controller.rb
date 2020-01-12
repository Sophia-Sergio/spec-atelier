module Api
  class SessionsController < ApplicationController
    before_action :valid_session, except: %i[create google_auth google_auth_failure]

    def create
      user = User.find_by(email: params['user']['email'])
      if user.try(:authenticate, params['user']['password']).present?
        start_session(user)
        render json: { logged_in: user.active?, user: BasicUserPresenter.decorate(current_user) }, status: :created
      elsif user&.google_token.present?
        render json: { error: 'you signed up with google' }, status: :not_found
      else
        render json: { error: 'email or password not found' }, status: :not_found
      end
    end

    def logged_in
      if current_user.present?
        render json: { logged_in: current_user.active?, user: BasicUserPresenter.decorate(current_user) }, status: :ok
      else
        render json: { logged_in: false }, status: :not_found
      end
    end

    def logout
      end_session
      render json: { logged_out: true }, status: :ok
    end

    def google_auth
      omniouth_handler_login
      render json: { logged_in: current_user.active?, user: BasicUserPresenter.decorate(current_user) }, status: :created
    end

    def google_auth_failure
      render json: { error: 'google auth failure' }, status: :internal_server_error
    end

    private

    def omniouth_handler_login
      user = User.where(email: user_params[:email]).first_or_initialize
      user.google_token = user_params[:google_token]
      if user.new_record?
        user.password = SecureRandom.hex(10) if user.password.nil?
        user.update(user_params)
      else
        user.save
      end
      start_session(user)
    end

    def user_params
      params.require(:user).permit(:first_name, :email, :last_name, :google_token, :profile_image)
    end
  end
end
