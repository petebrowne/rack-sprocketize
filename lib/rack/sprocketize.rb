require 'rack'

module Rack
  class Sprocketize
    autoload :Sprocket, 'rack/sprocketize/sprocket'
    autoload :VERSION,  'rack/sprocketize/version'
    
    DEFAULT_OPTIONS = {
      :source_path => 'app/javascripts',
      :output_path => 'public/javascripts',
      :load_path   => %w(vendor/javascripts)
    }.freeze
    
    class << self
      attr_accessor :options, :source_path, :output_path, :environment
      
      def production?
        self.environment.to_s == 'production'
      end
    end
    
    def initialize(app, options = {})
      @app = app
      
      Sprocketize.options     = DEFAULT_OPTIONS.dup.merge(options)
      Sprocketize.source_path = ::File.expand_path Sprocketize.options.delete(:source_path)
      Sprocketize.output_path = ::File.expand_path Sprocketize.options.delete(:output_path)
      Sprocketize.environment = if defined?(RAILS_ENV)
        RAILS_ENV # Rails 2
      elsif defined?(Rails) && defined?(Rails.env)
        Rails.env # Rails 3
      elsif defined?(@app.settings) && defined?(@app.settings.environment)
        @app.settings.environment # Sinatra
      elsif ENV.key?('RACK_ENV')
        ENV['RACK_ENV']
      else
        :development
      end
    end
    
    def call(env)
      @request = Rack::Request.new(env)
      sprocketize unless skip?
      @app.call(env)
    end
    
    protected
    
      def skip?
        if Sprocketize.production?
          @sprocketized && @request.params['sprocketize'].nil?
        else
          false
        end
      end
      
      def source_files
        files = Dir.glob ::File.join(Sprocketize.source_path, '**/*.js')
        files.reject! { |file| ::File.basename(file) =~ /^_/ }
        files
      end
    
      def sprocketize
        source_files.each do |source_file|
          sprocket = Sprocket.new(source_file)
          sprocket.sprocketize if sprocket.stale?
        end
        @sprocketized = true
      end
  end
end
