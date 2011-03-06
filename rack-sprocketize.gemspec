# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rack/sprocketize/version'

Gem::Specification.new do |s|
  s.name        = 'rack-sprocketize'
  s.version     = Rack::Sprocketize::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = %w(Pete Browne)
  s.email       = %w(me@petebrowne.com)
  s.homepage    = ''
  s.summary     = %{TODO: Write a gem summary}
  s.description = %{TODO: Write a gem description}

  s.rubyforge_project = 'rack-sprocketize'
  
  s.add_dependency             'rack',             '~> 1.2.1'
  s.add_dependency             'sprockets',        '~> 1.0.2'
  s.add_development_dependency 'rspec',            '~> 2.5.0'
  s.add_development_dependency 'test-construct',   '~> 1.2.0'
  s.add_development_dependency 'jsmin',            '~> 1.0.1'
  s.add_development_dependency 'packr',            '~> 3.1.0'
  s.add_development_dependency 'yui-compressor',   '~> 0.9.4'
  s.add_development_dependency 'closure-compiler', '~> 1.0.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = %w(lib)
end
