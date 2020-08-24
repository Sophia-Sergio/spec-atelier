module Api
  class PasswordsController < ApplicationController
    def forgot
      return render json: { error: 'Email not present' }, status: :not_found if params[:email].blank?

      user = User.find_by(email: params[:email])
      if user.present?
        user.generate_password_token!
        UserMailer.password_reset(user).deliver
        render json: { status: 'ok' }, status: :ok
      else
        render json: { error: 'Email address not found. Please check and try again.' }, status: :not_found
      end
    end

    def reset
      if params[:token].blank? || params[:password].blank?
        return render json: { error: 'Token not present' }, status: :not_found
      end

      user = User.find_by(reset_password_token: params[:token].to_s)
      if user.present? && user.password_token_valid?
        UserMailer.password_reset_success(user).deliver
        return render json: { status: 'password updated' }, status: :ok if user.reset_password!(params[:password])

        render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      else
        render json: { error: 'Link not valid or expired' }, status: :not_found
      end
    end
  end
end
