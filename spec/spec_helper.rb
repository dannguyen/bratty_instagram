# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require 'pry'

require File.expand_path '../../app.rb', __FILE__
ENV['RACK_ENV'] = 'test'

module SpecFixtures
  FIXTURE_DIR = File.expand_path '../fixtures', __FILE__
  def get_fixture(filename)
    fname = File.join FIXTURE_DIR, filename
    data = open(fname){ |f| f.read }
    case fname[/(?<=\.)\w+$/]
    when 'json'
      JSON.parse(data)
    when 'yml', 'yaml'
      YAML.load(data)
    else
      data
    end
  end

end


module RSpecMixin
  include Rack::Test::Methods
  def app
    BrattyPack::App
  end
end

# For RSpec 2.x
RSpec.configure do |c|
  c.include RSpecMixin
  c.include SpecFixtures
  c.order = "random"
  # Use color in STDOUT
  c.color_enabled = true
  # Use color not only in STDOUT but also in pagers and files
  c.tty = true
  # Use the specified formatter
  c.formatter = :documentation # :progress, :html, :textmate
  c.filter_run_excluding skip: true
  c.run_all_when_everything_filtered = true
  c.filter_run :focus => true
end
