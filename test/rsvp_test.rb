require_relative "helper"

class BadBudsTest < Minitest::Test
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
    assert_includes last_response.body,
                    "Your name must be between 1 and 20 characters."
  end

  def test_rsvp_anon_player_empty_name
    post "/games/1/players/add", { player_name: "  " }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Your name must be between 1 and 20 characters."
  end

  def test_rsvp_anon_player_long_name
    post "/games/1/players/add",
         { player_name: "Chico Harpo Groucho Gummo and Zeppo" },
         logged_in_as_peter

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Your name must be between 1 and 20 characters."

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

  def test_remove_player
    post "/games/1/players/4/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Player removed from this game.", session[:success]
  end

  def test_remove_player_no_permission
    post "/games/1/players/4/remove"

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "You must be logged in to do that."
  end

  def test_remove_invalid_player_from_game1
    post "/games/1/players/15/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "The specified player was not found."
  end

  def test_remove_invalid_player_from_game2
    post "/games/1/players/abc/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Invalid player."
  end

  def test_remove_invalid_player_from_game3
    post "/games/1/players/1abc/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Invalid player."
  end

  def test_remove_player_from_invalid_game1
    post "/games/15/players/1/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "The specified game was not found."
  end

  def test_remove_player_from_invalid_game2
    post "/games/abc/players/1/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Invalid game."
  end

  def test_remove_player_from_invalid_game3
    post "/games/1abc/players/1/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Invalid game."
  end
end
