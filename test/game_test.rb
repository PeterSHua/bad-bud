require_relative "helper"

class BadBudsTest < Minitest::Test
  def test_view_create_game
    get "/games/create", {}, logged_in_as_david

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Create Game"
  end

  def test_view_create_game_no_permission
    get "/games/create"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_create_game
    skip
  end

  def test_create_game_no_permission
    skip
  end

  def test_create_game_location_too_short
    skip
  end

  def test_create_game_location_too_long
    skip
  end

  def test_create_game_invalid_slots
    skip
  end

  def test_create_game_slots_too_high
    skip
  end

  def test_create_game_invalid_fee
    skip
  end

  def test_create_game_fee_too_high
    skip
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

  def test_view_game_not_found
    get "/games/9"

    assert_equal 302, last_response.status
    assert_equal "The specified game was not found.", session[:error]
  end

  def test_view_invalid_game1
    get "/games/abc"

    assert_equal 302, last_response.status
    assert_equal "Invalid game.", session[:error]
  end

  def test_view_invalid_game2
    get "/games/1abc"

    assert_equal 302, last_response.status
    assert_equal "Invalid game.", session[:error]
  end

  def test_edit_game
    skip
  end

  def test_edit_game_no_permission
    skip
  end

  def test_edit_invalid_game
    skip
  end

  def test_edit_game_location_too_short
    skip
  end

  def test_edit_game_location_too_long
    skip
  end

  def test_edit_game_invalid_slots
    skip
  end

  def test_edit_game_slots_too_high
    skip
  end

  def test_edit_game_invalid_fee
    skip
  end

  def test_edit_game_fee_too_high
    skip
  end

  def test_delete_game
    post "/games/1/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "Game has been deleted."

    refute_includes last_response.body, "Monday, Jul 25"
  end

  def test_delete_game_no_permission
    skip
  end

  def test_delete_invalid_game
    post "/games/20/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "You don't have permission to do that!"
  end
end
