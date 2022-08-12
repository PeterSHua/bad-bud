ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../bad_buds"

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

  def session
    last_request.env["rack.session"]
  end

  def logged_in_as_david
    {
      "rack.session" => {
                          logged_in: true,
                          username: "david",
                          player_id: 2
                        }
    }
  end

  def logged_in_as_peter
    {
      "rack.session" => {
                          logged_in: true,
                          username: "peter",
                          player_id: 1
                        }
    }
  end

  def test_view_game_list
    get "/game_list"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Monday, Jul 25"
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Badminton Vancouver"
    assert_includes last_response.body, "3 / 18"
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
    assert_includes last_response.body, "Monday, Jul 25"
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "3 / 18"
  end

  def test_view_invalid_group
    get "/groups/9"

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_view_game
    get "/games/1"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Jul 25"
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Badminton Vancouver"
    assert_includes last_response.body, "Attendees: 3 / 18"
    assert_includes last_response.body, "Fee: $12"
    assert_includes last_response.body, "E-transfer the fee to David"
  end

  def test_view_invalid_game
    get "/games/9"

    assert_equal 302, last_response.status
    assert_equal "The specified game was not found.", session[:error]
  end

  def test_view_player
    get "/players/2"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "David C"
    assert_includes last_response.body, "Rating:</a> 3"
    assert_includes last_response.body, "Founder of Novice BM Vancouver"
  end

  def test_view_invalid_player
    get "/players/9"

    assert_equal 302, last_response.status
    assert_equal "The specified player was not found.", session[:error]
  end

  def test_login
    get "/login"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Username"
    assert_includes last_response.body, "Password"

    post "/login", { username: "david", password: "abc123" }

    assert_equal 302, last_response.status
    assert_equal "Welcome!", session[:success]
    assert_equal "david", session[:username]
    assert_equal "2", session[:player_id]
    assert session[:logged_in]

    get last_response["Location"]
    assert_includes last_response.body, "&#128075;david"
  end

  def test_login_fail
    post "/login", { username: "groucho", password: "marx" }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Invalid Credentials!"
    refute session[:logged_in]
  end

  def test_logout
    post "/login", { username: "david", password: "abc123" }
    get last_response["Location"]

    assert_includes last_response.body, "Sign Out"

    post "/logout"

    assert_equal 302, last_response.status
    assert_equal "You have been signed out.", session[:success]

    get last_response["Location"]

    assert_equal 200, last_response.status
    refute_equal "Welcome!", session[:success]
    refute_equal "david", session[:username]
    refute_equal "1", session[:player_id]
    refute session[:logged_in]

    assert_includes last_response.body, "Sign In"
  end

  def test_register
    post "/register", { username: "groucho", password: "marx" }
    get last_response["Location"]

    assert_includes last_response.body, "&#128075;groucho"

    post "/logout"

    assert_equal 302, last_response.status
    assert_equal "You have been signed out.", session[:success]

    get last_response["Location"]

    assert_equal 200, last_response.status
    refute session[:logged_in]
    assert_includes last_response.body, "Sign In"
  end

  def test_register_already_logged_in
    post "/register", { username: "harpo", password: "marx" }, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "You're already logged in.", session[:error]
  end

  def test_register_acc_exists
    post "/register", { username: "david", password: "abc123" }

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
    assert_equal "Player has been signed up.", session[:success]

    get last_response["Location"]

    assert_includes last_response.body, "Groucho Marx"
  end

  def test_rsvp_anon_player_short_name
    post "/games/1/players/add", { player_name: "" }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Your name must be between 1 and 20 characters."
  end

  def test_rsvp_anon_player_long_name
    post "/games/1/players/add", { player_name: "Chico Harpo Groucho Gummo and Zeppo" }, logged_in_as_peter

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Your name must be between 1 and 20 characters."

    refute_includes last_response.body, "Chico Harpo Groucho Gummo and Zeppo"
  end

  def test_rsvp_anon_player_no_empty_slots
    post "/games/2/players/add", { player_name: "Chico" }
    post "/games/2/players/add", { player_name: "Harpo" }
    post "/games/2/players/add", { player_name: "Groucho" }
    post "/games/2/players/add", { player_name: "Gummo" }
    post "/games/2/players/add", { player_name: "Zeppo" }
    post "/games/2/players/add", { player_name: "Minnie" }

    post "/games/2/players/add", { player_name: "Sam" }

    assert_equal 302, last_response.status
    assert_equal "Sorry, no empty slots remaining.", session[:error]

    get last_response["Location"]

    refute_includes last_response.body, "Sam"
  end

  def test_rvsp_player
    post "/games/1/players/add", { player_name: "joe" }, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Player has been signed up.", session[:success]

    get last_response["Location"]

    assert_includes last_response.body, "joe"
  end

  def test_rsvp_registered_player_already_rsvpd
    post "/games/3/players/1/add", {}, logged_in_as_peter
    get last_response["Location"]
    post "/games/3/players/1/add", {}, logged_in_as_peter

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Player already signed up!"
  end

  def test_rsvp_player_no_empty_slots
    post "/games/2/players/add", { player_name: "Chico" }, logged_in_as_david
    post "/games/2/players/add", { player_name: "Harpo" }
    post "/games/2/players/add", { player_name: "Groucho" }
    post "/games/2/players/add", { player_name: "Gummo" }
    post "/games/2/players/add", { player_name: "Zeppo" }

    post "/games/2/players/add", { player_name: "Minnie" }

    assert_equal 302, last_response.status
    assert_equal "Sorry, no empty slots remaining.", session[:error]

    get last_response["Location"]

    refute_includes last_response.body, "Minnie"
  end

  def test_unrsvp_player
    post "/games/1/players/4/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Player removed from this game.", session[:success]
  end

  def test_unrsvp_player_no_permission
    post "/games/1/players/4/remove"

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "You don't have permission to do that!"
  end

  def test_unrsvp_player_not_signed_up
    post "/games/4/players/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "You aren't signed up for this game!"
  end

  def test_confirm_payment
    post "/games/1/players/4/remove", {}, logged_in_as_david
    post "/games/1/players/5/remove", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "&#10060;"

    post "/games/1/players/1/confirm_paid"

    get last_response["Location"]
    assert_includes last_response.body, "&#9989;"
  end

  def test_confirm_payment_no_permission
    post "/games/1/players/4/remove", {}, logged_in_as_david
    post "/games/1/players/5/remove", {}, logged_in_as_david

    post "/logout"
    get last_response["Location"]

    post "/games/1/players/1/confirm_paid"
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "You don't have permission to do that!"
  end

  def test_un_confirm_payment
    post "/games/1/players/4/remove", {}, logged_in_as_david
    post "/games/1/players/5/remove", {}, logged_in_as_david

    post "/games/1/players/1/unconfirm_paid"

    get last_response["Location"]
    refute_includes last_response.body, "&#9989;"
  end

  def test_un_confirm_payment_no_permission
    post "/games/1/players/4/remove", {}, logged_in_as_david
    post "/games/1/players/5/remove", {}, logged_in_as_david

    post "/logout"
    get last_response["Location"]

    post "/games/1/players/1/unconfirm_paid"

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "You don't have permission to do that!"
  end

  def test_confirm_all_payment
    post "/games/1/players/confirm_all", {}, logged_in_as_david

    get last_response["Location"]
    refute_includes last_response.body, "&#10004;"
  end

  def test_confirm_all_payment_no_permission
    post "/games/1/players/confirm_all"

    get last_response["Location"]
    assert_includes last_response.body, "You don't have permission to do that!"
  end

  def test_unconfirm_all_payment
    post "/games/1/players/confirm_all"
    post "/games/1/players/unconfirm_all"

    get last_response["Location"]
    refute_includes last_response.body, "&#9989;"
  end

  def test_unconfirm_all_payment_no_permission

  end

  def test_create_game
    skip
  end

  def test_delete_game
    post "/games/1/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "Game has been deleted."

    refute_includes last_response.body, "Monday, Jul 25"
  end

  def test_delete_game_no_permission

  end

  def test_delete_game_doesnt_exist
    post "/games/20/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "You don't have permission to do that!"
  end

  def test_create_group
    skip
  end

  def test_create_group_no_permission
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

  def test_delete_group_no_permission
    skip
  end

  def test_view_add_game_to_group_schedule_for_day_of_week
    skip
  end

  def test_view_add_game_to_group_schedule_for_day_of_week_no_permission
    skip
  end

  def test_add_game_to_group_schedule_for_day_of_week
    skip
  end

  def test_add_game_to_group_schedule_for_day_of_week_no_permission
    skip
  end

  def test_view_schedule
    skip
  end

  def test_view_schedule_no_permission
    skip
  end

  def test_edit_group_schedule_notes
    skip
  end

  def test_edit_group_schedule_notes_no_permission
    skip
  end

  def test_edit_group_schedule_notes_too_long
    skip
  end

  def test_view_group_schedule_day_games
    skip
  end

  def test_view_group_schedule_day_games_no_permission
    skip
  end

  def test_view_add_game_to_group_schedule_for_day_of_week
    skip
  end

  def test_view_add_game_to_group_schedule_for_day_of_week_no_permission
    skip
  end

  def test_add_game_to_group_schedule_for_day_of_week
    skip
  end

  def test_add_game_to_group_schedule_for_day_of_week_location_too_short
    skip
  end

  def test_add_game_to_group_schedule_for_day_of_week_location_too_long
    skip
  end

  def test_add_game_to_group_schedule_for_day_of_week_slots_too_small
    skip
  end

  def test_add_game_to_group_schedule_for_day_of_week_slots_too_large
    skip
  end

  def test_add_game_to_group_schedule_for_day_of_week_fee_too_large
    skip
  end
 end
