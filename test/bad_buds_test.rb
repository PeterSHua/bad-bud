ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../bad_buds"
require_relative "test_helpers.rb"

class BadBudsTest < Minitest::Test
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

  def test_view_game_list
    get "/game_list"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Monday, Jul 25"
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Badminton Vancouver"
    assert_includes last_response.body, "3 / 18"
  end

  def test_view_group_list
    get "/group_list"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Beginner/intermediate games every week"
  end
end
