source :rubygems

gem 'rack',             '~> 1.2.0'
gem 'sprockets',        '~> 1.0.2'
gem 'valuable',         '~> 0.8.5'

group :development do
  gem 'rake',             '>= 0.8.7'
  gem 'rspec',            '~> 2.6.0'
  gem 'test-construct',   '~> 1.2.0'
  gem 'jsmin',            '~> 1.0.1'
  gem 'packr',            '~> 3.1.0'
  gem 'yui-compressor',   '~> 0.9.4'
  gem 'closure-compiler', '~> 1.0.0'
end
