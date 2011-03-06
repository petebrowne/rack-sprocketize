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
      attr_accessor :options, :compression_options, :source_path, :output_path, :always_check, :compress
      
      def configure(options = {})
        self.options             = DEFAULT_OPTIONS.dup.merge(options)
        self.compression_options = self.options.delete(:compression_options) || {}
        self.source_path         = ::File.expand_path self.options.delete(:source_path)
        self.output_path         = ::File.expand_path self.options.delete(:output_path)
      
        self.always_check = if self.options.key?(:always_check)
          self.options.delete(:always_check)
        else
          self.environment == 'development'
        end
      
        self.compress = if self.options.key?(:compress)
          self.options.delete(:compress)
        else
          self.environment == 'production'
        end
      end
      
      def environment
        if defined?(RAILS_ENV)
          RAILS_ENV # Rails 2
        elsif defined?(Rails) && defined?(Rails.env)
          Rails.env.to_s # Rails 3
        elsif defined?(@app.settings) && defined?(@app.settings.environment)
          @app.settings.environment # Sinatra
        elsif ENV.key?('RACK_ENV')
          ENV['RACK_ENV']
        else
          'development'
        end
      end
      
      def always_check?
        !!@always_check
      end
      
      def compress?
        !!@compress
      end
    end
    
    def initialize(app, options = {})
      @app = app
      Sprocketize.configure(options)
    end
    
    def call(env)
      @request = Rack::Request.new(env)
      sprocketize unless skip?
      @app.call(env)
    end
    
    protected
    
      def skip?
        return false if Sprocketize.always_check?
        @sprocketized && @request.params['sprocketize'].nil?
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
