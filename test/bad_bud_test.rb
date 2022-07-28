ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "pry-byebug"

require_relative "../bad_buds"

class BadBudsTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    @storage = DatabasePersistence.new
    @storage.delete_all_schema
    @storage.create_schema
    player_1 = Player.new(id: 1,
                          name: 'Peter H',
                          rating: 3,
                          games_played: 30,
                          about: 'Info about Peter.',
                          username: 'peter',
                          password: '$2a$12$O.pnaqSa.yreN2v02FrE0uDedhSmKAzjR8vyqN3kBV5dLJrGLIG/y')

    player_2 = Player.new(id: 2,
                          name: 'David M',
                          rating: 3,
                          games_played: 50,
                          about: 'Info about David.',
                          username: 'david',
                          password: '$2a$12$O.pnaqSa.yreN2v02FrE0uDedhSmKAzjR8vyqN3kBV5dLJrGLIG/y')

    group_1 = Group.new(id: 1,
                        name: 'Novice BM Vancouver',
                        about: 'Casual games')

    location_1 = Location.new(id: 1,
                              name: 'Badminton Vancouver',
                              address: '13100 Mitchell Rd SUITE 110, Richmond, BC V6V 1M8',
                              phone_number: '(604) 325-5128',
                              cost_per_court: 40)

    game_1 = Game.new(id: 1,
                      start_time: '2022-07-22 17:00:00',
                      duration: 2,
                      group_name: 'Novice BM Vancouver',
                      group_id: 1,
                      location_name: 'Badminton Vancouver',
                      location_id: 1,
                      fee: 12,
                      total_slots: 18,
                      filled_slots: 2,
                      players: { name: 'Peter H', has_paid: true },
                      notes: 'Some game notes.')

    @storage.add_player(player_1)
    @storage.add_location(location_1)
    @storage.add_group(group_1)
    @storage.add_game(game_1)
  end

  def teardown
    @storage.delete_all_data
    @storage.delete_all_schema
  end

  def session
    last_request.env["rack.session"]
  end

  def admin_session
    { "rack.session" => { logged_in: true } }
  end

  def test_game_list
    get "/game_list"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Fri, Jul 22"
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Location: Badminton Vancouver"
    assert_includes last_response.body, "Attendees: 0 / 18"
    assert_includes last_response.body, "Fee: $12"
  end
 end
