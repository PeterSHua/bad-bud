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
                          name: 'Symere Woods',
                          rating: 3,
                          games_played: 30,
                          about: 'Info about symere.',
                          username: 'symere',
                          password: '$2a$12$W5ACHXiMPoYIHUEjTWtnUOnO18zfz65mQiqsIn/IVabLsJQ5ZelqS')

    player_2 = Player.new(id: 2,
                          name: 'Jeffery Williams',
                          rating: 3,
                          games_played: 50,
                          about: 'Info about jeffery.',
                          username: 'jeffery',
                          password: '$2a$12$W5ACHXiMPoYIHUEjTWtnUOnO18zfz65mQiqsIn/IVabLsJQ5ZelqS')

    group_1 = Group.new(id: 1,
                        name: 'Novice BM Vancouver',
                        about: 'Beginner/intermediate games every week')

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
                      total_slots: 6,
                      filled_slots: 2,
                      players: { name: 'Symere Woods', has_paid: true },
                      notes: 'Some game notes.')

    @storage.add_player(player_1)
    @storage.add_player(player_2)
    @storage.add_location(location_1)
    @storage.add_group(group_1)
    @storage.make_organizer(1, 1)
    @storage.make_organizer(1, 2)
    @storage.add_game(game_1)
  end

  def teardown
    @storage.delete_all_data
    @storage.delete_all_schema
  end

  def session
    last_request.env["rack.session"]
  end

  def logged_in_as_symere
    {
      "rack.session" => {
                          logged_in: true,
                          username: "symere",
                          player_id: 1
                        }
    }
  end

  def logged_in_as_jeffery
    {
      "rack.session" => {
                          logged_in: true,
                          username: "jeffery",
                          player_id: 2
                        }
    }
  end

  def test_view_game_list
    get "/game_list"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Fri, Jul 22"
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Badminton Vancouver"
    assert_includes last_response.body, "0 / 6"
  end

  def test_view_group_list
    get "/group_list"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Beginner/intermediate games every week"
  end

  def test_view_group
    get "/groups/1"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Fri, Jul 22"
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Location: Badminton Vancouver"
    assert_includes last_response.body, "Attendees: 0 / 6"
    assert_includes last_response.body, "Fee: $12"
  end

  def test_view_invalid_group
    get "/groups/2"

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_view_game
    get "/games/1"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Fri, Jul 22"
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Location: Badminton Vancouver"
    assert_includes last_response.body, "Attendees: 0 / 6"
    assert_includes last_response.body, "Fee: $12"
    assert_includes last_response.body, "Some game notes."
  end

  def test_view_invalid_game
    get "/games/2"

    assert_equal 302, last_response.status
    assert_equal "The specified game was not found.", session[:error]
  end

  def test_view_player
    get "/players/1"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Symere Woods"
    assert_includes last_response.body, "Rating:</a> 3"
    assert_includes last_response.body, "Games played: 30"
    assert_includes last_response.body, "Info about symere."
  end

  def test_view_invalid_player
    get "/players/3"

    assert_equal 302, last_response.status
    assert_equal "The specified player was not found.", session[:error]
  end

  def test_login
    get "/login"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Username"
    assert_includes last_response.body, "Password"

    post "/login", { username: "symere", password: "abc123" }

    assert_equal 302, last_response.status
    assert_equal "Welcome!", session[:success]
    assert_equal "symere", session[:username]
    assert_equal "1", session[:player_id]
    assert session[:logged_in]

    get last_response["Location"]
    assert_includes last_response.body, "Signed in as <a href=\"/players/1\">symere"
  end

  def test_login_fail
    post "/login", { username: "groucho", password: "marx" }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Invalid Credentials!"
    refute session[:logged_in]
  end

  def test_logout
    post "/login", { username: "symere", password: "abc123" }
    get last_response["Location"]

    assert_includes last_response.body, "Sign Out"

    post "/logout"

    assert_equal 302, last_response.status
    assert_equal "You have been signed out.", session[:success]

    get last_response["Location"]

    assert_equal 200, last_response.status
    refute_equal "Welcome!", session[:success]
    refute_equal "symere", session[:username]
    refute_equal "1", session[:player_id]
    refute session[:logged_in]

    assert_includes last_response.body, "Sign In"
  end

  def test_register
    post "/register", { username: "groucho", password: "marx" }
    get last_response["Location"]

    assert_includes last_response.body, "Signed in as"

    post "/logout"

    assert_equal 302, last_response.status
    assert_equal "You have been signed out.", session[:success]

    get last_response["Location"]

    assert_equal 200, last_response.status
    refute session[:logged_in]
    assert_includes last_response.body, "Sign In"
  end

  def test_register_already_logged_in
    post "/register", { username: "harpo", password: "marx" }, logged_in_as_symere

    assert_equal 302, last_response.status
    assert_equal "You're already logged in.", session[:error]
  end

  def test_register_acc_exists
    post "/register", { username: "symere", password: "abc123" }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "That account name already exists."
  end

  def test_register_short_username
    post "/register", { username: "gro", password: "marx" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Username must consist of only letters and numbers, "\
                    "and must be between 4-10 characters."
  end

  def test_register_long_username
    post "/register", { username: "groucho1234", password: "marx" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Username must consist of only letters and numbers, "\
                    "and must be between 4-10 characters."
  end

  def test_register_invalid_chars_username
    post "/register", { username: "gr[]ucho", password: "marx" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Username must consist of only letters and numbers, "\
                    "and must be between 4-10 characters."
  end

  def test_register_short_password
    post "/register", { username: "groucho", password: "mar" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Password must be between 4-10 characters and cannot "\
                    "contain spaces."
  end

  def test_register_long_password
    post "/register", { username: "groucho", password: "marx1234567" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Password must be between 4-10 characters and cannot "\
                    "contain spaces."
  end

  def test_register_invalid_chars_password
    post "/register", { username: "groucho", password: "m a r x" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Password must be between 4-10 characters and cannot "\
                    "contain spaces."
  end

  def test_rsvp_anon_player
    post "/games/1/players/add", { player_name: "Groucho Marx" }

    assert_equal 302, last_response.status
    assert_equal "You've been signed up.", session[:success]

    get last_response["Location"]

    assert_includes last_response.body, "Groucho Marx"
  end

  def test_rsvp_anon_player_short_name
    post "/games/1/players/add", { player_name: "" }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Your name must be between 1 and 20 characters."
  end

  def test_rsvp_anon_player_long_name
    post "/games/1/players/add", { player_name: "Chico Harpo Groucho Gummo and Zeppo" }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Your name must be between 1 and 20 characters."

    refute_includes last_response.body, "Chico Harpo Groucho Gummo and Zeppo"
  end

  def test_rsvp_anon_player_no_empty_slots
    post "/games/1/players/add", { player_name: "Chico" }
    post "/games/1/players/add", { player_name: "Harpo" }
    post "/games/1/players/add", { player_name: "Groucho" }
    post "/games/1/players/add", { player_name: "Gummo" }
    post "/games/1/players/add", { player_name: "Zeppo" }
    post "/games/1/players/add", { player_name: "Minnie" }

    post "/games/1/players/add", { player_name: "Sam" }

    assert_equal 302, last_response.status
    assert_equal "Sorry, no empty slots remaining.", session[:error]

    get last_response["Location"]

    refute_includes last_response.body, "Sam"
  end

  def test_rvsp_player
    post "/games/1/players/add", {}, logged_in_as_symere

    assert_equal 302, last_response.status
    assert_equal "You've been signed up.", session[:success]

    get last_response["Location"]

    assert_includes last_response.body, "Symere Woods"
  end

  def test_rsvp_player_already_rsvpd
    post "/games/1/players/add", {}, logged_in_as_symere
    post "/games/1/players/add", {}

    assert_equal 422, last_response.status
    assert_includes last_response.body, "You're already signed up!"
  end

  def test_rsvp_player_no_empty_slots
    post "/games/1/players/add", { player_name: "Chico" }
    post "/games/1/players/add", { player_name: "Harpo" }
    post "/games/1/players/add", { player_name: "Groucho" }
    post "/games/1/players/add", { player_name: "Gummo" }
    post "/games/1/players/add", { player_name: "Zeppo" }
    post "/games/1/players/add", { player_name: "Minnie" }

    post "/games/1/players/add", {}, logged_in_as_symere

    assert_equal 302, last_response.status
    assert_equal "Sorry, no empty slots remaining.", session[:error]

    get last_response["Location"]

    refute_includes last_response.body, "Symere Woods"
  end

  def test_unrsvp_player
    post "/games/1/players/add", {}, logged_in_as_symere
    post "/games/1/players/remove"

    assert_equal 302, last_response.status
    assert_equal "You have been removed from this game.", session[:success]

    get last_response["Location"]

    refute_includes last_response.body, "Symere Woods"
  end

  def test_unrsvp_player_not_signed_up
    post "/games/1/players/remove", {}, logged_in_as_symere

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "You aren't signed up for this game!"
  end

  def test_confirm_payment
    post "/games/1/players/add", {}, logged_in_as_symere

    get last_response["Location"]
    assert_includes last_response.body, "❌"

    post "/games/1/players/1/confirm_paid"

    get last_response["Location"]
    assert_includes last_response.body, "✅"
  end

  def test_un_confirm_payment
    post "/games/1/players/add", {}, logged_in_as_symere
    post "/games/1/players/1/confirm_paid"
    post "/games/1/players/1/unconfirm_paid"

    get last_response["Location"]
    assert_includes last_response.body, "❌"
  end

  def test_confirm_all_payment
    post "/games/1/players/add", {}, logged_in_as_symere
    post "/games/1/players/add", {}, logged_in_as_jeffery
    post "/games/1/players/confirm_all"

    get last_response["Location"]
    refute_includes last_response.body, "❌"
  end

  def test_unconfirm_all_payment
    post "/games/1/players/add", {}, logged_in_as_symere
    post "/games/1/players/add", {}, logged_in_as_jeffery
    post "/games/1/players/confirm_all"
    post "/games/1/players/unconfirm_all"

    get last_response["Location"]
    refute_includes last_response.body, "✅"
  end

  def organizer_remove_player_from_game
    post "/games/1/players/add", {}, logged_in_as_symere
    post "/games/1/players/add", {}, logged_in_as_jeffery

    post "/games/1/players/1/remove"

    assert_equal 302, last_response.status
    assert_equal "Player removed from this game.", session[:success]

    get last_response["Location"]

    refute_includes last_response.body, "Symere Woods"
  end

  def organizer_remove_player_not_signed_up_for_game
    post "/games/1/players/1/remove", {}, logged_in_as_symere

    assert_equal 422, last_response.status
    assert_equal "Player isn't signed up for this game!", session[:error]
  end

  def test_create_game
    skip
  end

  def test_delete_game
    skip
  end

  def test_create_group
    skip
  end

  def test_create_group_already_exists
    skip
  end

  def test_create_group_short_name
    skip
  end

  def test_create_group_long_name
    skip
  end

  def test_create_group_invalid_chars_name
    skip
  end

  def test_delete_group
    skip
  end
 end
