ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  config.action_controller.session_store = :active_record_store

  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# Include your application configuration below
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
    :cz_datetime => "%d.%m.%Y %H:%M",
    :cz_time => "%H:%M",
    :cz_date => "%d.%m.%Y" 
)

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
    :cz_date => "%d.%m.%Y",
    :cz_datetime => "%d.%m.%Y %H:%M"
)


ActionMailer::Base.default_charset = "UTF-8"
ActionMailer::Base.delivery_method = :sendmail


ExceptionNotifier.exception_recipients = %w(jbosss@gmail.com)

