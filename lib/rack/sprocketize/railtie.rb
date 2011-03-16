require 'rack-sprocketize'
require 'rails'

module Rack
  class Sprocketize
    class Railtie < Rails::Railtie
      config.sprocketize = ActiveSupport::OrderedOptions.new
      
      initializer 'rack-sprocketize.initialize' do |app|
        app.middleware.use Rack::Sprocketize, app.config.sprocketize
      end
    end
  end
end
