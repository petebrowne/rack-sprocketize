require 'fileutils'
require 'sprockets'

module Rack
  class Sprocketize
    class Sprocket
      def initialize(source_file)
        @source_file = source_file
        @output_path = @source_file.sub /^#{Regexp.escape(Sprocketize.source_path)}/, Sprocketize.output_path
        @secretary   = Sprockets::Secretary.new Sprocketize.options.merge(:source_files => [ @source_file ])
      end
      
      def compress(output)
        if defined?(JSMin)
          JSMin.minify(output)
        elsif defined?(Packr)
          Packr.pack output, compression_options(:shrink_vars => true)
        elsif defined?(YUI) and defined?(YUI::JavaScriptCompressor)
          YUI::JavaScriptCompressor.new(compression_options(:munge => true)).compress(output)
        elsif defined?(Closure) and defined?(Closure::Compiler)
          Closure::Compiler.new(compression_options).compile(output)
        else
          output
        end
      end
      
      def concat
        @secretary.concatenation.to_s
      end
      
      def stale?
        !::File.exist?(@output_path) || @secretary.source_last_modified > ::File.mtime(@output_path)
      end
      
      def sprocketize
        FileUtils.mkdir_p ::File.dirname(@output_path)
        ::File.open(@output_path, 'w') do |file|
          output = concat
          output = compress(output) if Sprocketize.always_compress? && !already_compressed?
          file.write(output.strip)
        end
      end
      
      def already_compressed?
        ::File.basename(@source_file) =~ /(-|\.)min\.js/
      end
      
      protected
      
        def compression_options(defaults = {})
          defaults.merge Sprocketize.compression_options
        end
    end
  end
end
