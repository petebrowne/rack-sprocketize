lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'construct'
require 'rack/sprocketize'

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
end
