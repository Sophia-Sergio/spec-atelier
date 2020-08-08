module Api
  class RegistrationsController < ApplicationController
    def create
      user = User.new(email:                 params['user']['email'],
                      password:              params['user']['password'],
                      password_confirmation: params['user']['password'])
      if user.save
        start_session(user)
        UserMailer.send_signup_email(user).deliver
        render json: { logged_in: true, user: BasicUserPresenter.decorate(user) }, status: :created
      else
        render json: { error: user.errors.to_json }, status: :conflict
      end
    end
  end
end
