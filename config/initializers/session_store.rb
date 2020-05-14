if Rails.env.production?
  # Rails.application.config.session_store :cookie_store, key: '_back', domain: 'https://spec-atelier.herokuapp.com/'
elsif Rails.env.staging?
  Rails.application.config.session_store :cookie_store, key: '_back', domain: 'https://spec-atelier.herokuapp.com/'
else
  Rails.application.config.session_store :cookie_store, key: '_back'
end