ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "pry-byebug"

require_relative "../bad_bud"
require_relative "test_helpers.rb"

class BadBudTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    @storage = DatabasePersistence.new
    @storage.delete_data
    @storage.seed_data
  end

  def teardown
    @storage.delete_data
  end
end
