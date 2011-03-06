lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'construct'
require 'pathname'
require 'jsmin'
require 'packr'
require 'yui/compressor'
require 'closure-compiler'
require 'rack/sprocketize'

$hidden_consts = {}
[ :JSMin, :Packr, :YUI, :Closure ].each do |const|
  $hidden_consts[const] = Object.const_get(const)
  Object.send :remove_const, const
end

RSpec.configure do |config|
  config.include Construct::Helpers
  
  def app(*args)
    @app ||= Rack::Builder.app do
      use Rack::Lint
      use Rack::Sprocketize, *args
      run lambda { |env| [ 200, { 'Content-Type' => 'text/html' }, [ 'Hello World!' ] ] }
    end
  end
  
  def request(url = '/', options = {})
    Rack::MockRequest.env_for(url, options)
  end
  
  def reveal_const(const)
    begin
      Object.const_set const, $hidden_consts[const]
      yield
    ensure
      Object.send :remove_const, const
    end
  end
end
