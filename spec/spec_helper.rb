lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'rack/sprocketize'

RSpec.configure do |config|
  
end
