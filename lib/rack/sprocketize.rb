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
      attr_accessor :options, :source_path, :output_path
    end
    
    def initialize(app, options = {})
      @app = app
      
      Sprocketize.options     = DEFAULT_OPTIONS.dup.merge(options)
      Sprocketize.source_path = ::File.expand_path Sprocketize.options.delete(:source_path)
      Sprocketize.output_path = ::File.expand_path Sprocketize.options.delete(:output_path)
    end
    
    def call(env)
      sprocketize
      @app.call(env)
    end
    
    protected
      
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
      end
  end
end
