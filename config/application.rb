require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sms
  class Application < Rails::Application
    # Do not generate specs for views and requests. Also, do not generate assets.
    config.generators do |g|
      g.helper false
      g.view_specs false
      g.assets false
      g.integration_tool false
      g.controller_specs false
      g.mailer_specs false
      g.routing_specs false
      g.scaffold_controller :scaffold_controller
    end
    config.app_generators do |g|
      g.test_framework :rspec
    end

    # Prevent initializing your application and connect to the database on assets precompile.
    config.assets.initialize_on_precompile = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = ENV.fetch('TZ', 'Brasilia')


    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :'pt-BR'
    config.i18n.locale = :'pt-BR'

    config.autoload_paths += %W(#{config.root}/lib)

    Rails.application.config.assets.precompile += %w( admin/admin.css admin/admin.js public/public.css public/public.js representante/representante.css representante/representante.js )
  end
end
