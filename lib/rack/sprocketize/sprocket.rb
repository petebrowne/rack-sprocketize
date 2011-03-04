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
      
      def concat
        @secretary.concatenation.to_s
      end
      
      def stale?
        !::File.exist?(@output_path) || @secretary.source_last_modified > ::File.mtime(@output_path)
      end
      
      def sprocketize
        FileUtils.mkdir_p ::File.dirname(@output_path)
        ::File.open(@output_path, 'w') do |file|
          file.write(concat.strip)
        end
      end
    end
  end
end
