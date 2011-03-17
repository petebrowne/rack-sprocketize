require 'rack'

module Rack
  class Sprocketize
    autoload :Config,   'rack/sprocketize/config'
    autoload :Railtie,  'rack/sprocketize/railtie'
    autoload :Sprocket, 'rack/sprocketize/sprocket'
    autoload :VERSION,  'rack/sprocketize/version'
    
    attr_accessor :config
    
    def initialize(app, options = {})
      @app    = app
      @config = Config.new(options)
    end
    
    def call(env)
      @request = Rack::Request.new(env)
      sprocketize unless skip?
      @app.call(env)
    end
    
    protected
    
      def skip?
        return false if config.always_check?
        @sprocketized && @request.params['sprocketize'].nil?
      end
      
      def source_files
        files = Dir.glob ::File.join(config.source_path, '**/*.js')
        files.reject! { |file| ::File.basename(file) =~ /^_/ }
        files
      end
    
      def sprocketize
        source_files.each do |source_file|
          sprocket = Sprocket.new(source_file, config)
          sprocket.sprocketize if sprocket.stale?
        end
        @sprocketized = true
      end
  end
end

require 'rack/sprocketize/railtie' if defined?(Rails)
