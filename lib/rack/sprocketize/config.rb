require 'pathname'
require 'valuable'

module Rack
  class Sprocketize
    # Configuration options for Rack::Sprocketize.
    class Config < Valuable
      def initialize(*args)
        super
        self.always_compress = environment == 'production'  if always_compress.nil?
        self.always_check    = environment == 'development' if always_check.nil?
      end
      
      # Options that will be passed directly to Sprockets.
      #
      # Default: { :load_path => %w(vendor/javascripts) }
      has_value :sprockets, :default => { :load_path => %w(vendor/javascripts) }
      
      # Options that will be passed to the javascript compressor, if used.
      #
      # Default: {}
      has_value :compression, :default => {}
      
      # Enables javascript compression.
      #
      # Default: true in production environments, false otherwise
      has_value :always_compress, :klass => :boolean
      
      # When enabled, the javascripts will be checked for changes on every request.
      #
      # Default: true in development environments, false otherwise
      has_value :always_check, :klass => :boolean
      
      # Path to directory where the source javascripts are located.
      #
      # Default: 'app/javascripts'
      has_value :source_path, :default => 'app/javascripts'
      
      # Path to the directory where the sprocketized javascripts should be output.
      #
      # Default: 'public/javascripts'
      has_value :output_path, :default => 'public/javascripts'
      
      # Determines which environment we are currently in.
      #
      # Default: 'development'
      def environment
        if defined?(RAILS_ENV)
          RAILS_ENV # Rails 2
        elsif defined?(Rails) && defined?(Rails.env)
          Rails.env.to_s # Rails 3
        elsif ENV.key?('RACK_ENV')
          ENV['RACK_ENV']
        else
          'development'
        end
      end
    end
  end
end
