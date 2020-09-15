require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Back
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.middleware.use ActionDispatch::Cookies
    config.api_only = true

    #remove unused default routes
    initializer(:remove_action_mailbox_and_activestorage_routes, after: :add_routing_paths) { |app|
      app.routes_reloader.paths.delete_if {|path| path =~ /activestorage/ }
      app.routes_reloader.paths.delete_if {|path| path =~ /actionmailbox/ }
    }

    # config.middleware.insert_after(ActiveRecord::QueryCache, ActionDispatch::Cookies)
    config.middleware.insert_after(ActionDispatch::Cookies, ActionDispatch::Session::CookieStore)
    config.time_zone = 'America/Santiago'
    config.active_record.default_timezone = :local
    config.active_job.queue_adapter = :sidekiq
    config.autoload_paths << "#{Rails.root}/lib"

    env_file = File.join(Rails.root, 'config', 'local_env.yml')
    if (Rails.env.development? || Rails.env.test?) && File.exists?(env_file)
      config.before_configuration do
        YAML.load(File.open(env_file)).each {|key, value|  ENV[key.to_s] = value }
        config.generators do |g|
          g.template_engine :haml
          g.test_framework  :rspec, fixture: false
          g.view_specs      false
          g.helper_specs    false
        end
      end
    end
  end
end
