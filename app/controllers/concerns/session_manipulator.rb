module SessionManipulator
  extend ActiveSupport::Concern

  HOURS_EXPIRES_IN = 24

  def current_session
    @current_session ||= current_user&.session if current_user&.session&.active?
  end

  def current_user
    @current_user ||= begin
      auth_token = cookies.signed[:jwt].presence || header_token.presence || nil
      if auth_token.present?
        user_id = JsonWebToken.decode(auth_token)[:user_id]
        user    = User.find(user_id)
        put_cookie(auth_token) if cookies.signed[:jwt].blank? && header_token.present?
        user
      end
    end
  end

  def end_session
    current_session.update(active: false, expires: nil)
    cookies.delete(:jwt)
  end

  def start_session(user)
    token = token(user)
    put_cookie(token)
    Session.find_or_create_by(user: user).update(token: token, expires: expires)
  end

  def valid_session
    render json: { error: 'No session found' }, status: :unauthorized unless valid_session_conditions
  end

  private

  def header_token
    request.headers["Authorization"]&.remove('Bearer ')
  end

  def token(user)
    JsonWebToken.encode({ user_id: user.id }, expires)
  end

  def put_cookie(token)
    cookies.signed[:jwt] = { value: token, httponly: true, expires: expires }
  end

  def valid_session_conditions
    header_token.present? && current_session.active? && header_token == current_session.token && check_expires_date?
  end

  def check_expires_date?
    return true if current_session.expires >= Time.zone.now

    end_session
    false
  end

  def expires
    HOURS_EXPIRES_IN.hours.from_now
  end
end
