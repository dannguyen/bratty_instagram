# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require 'pry'

require File.expand_path '../../app.rb', __FILE__

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app
    BrattyPack::App
  end
end

# For RSpec 2.x
RSpec.configure do |c|
  c.include RSpecMixin
  c.order = "random"
  # Use color in STDOUT
  c.color_enabled = true
  # Use color not only in STDOUT but also in pagers and files
  c.tty = true
  # Use the specified formatter
  c.formatter = :documentation # :progress, :html, :textmate
end
