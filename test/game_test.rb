class BadBudsTest < Minitest::Test
  # rubocop: disable Metrics/AbcSize
  def test_create_game
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
  # rubocop: enable Metrics/AbcSize

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

  def test_delete_game
    post "/games/1/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "Game has been deleted."

    refute_includes last_response.body, "Monday, Jul 25"
  end

  def test_delete_game_no_permission
    test_view_add_game_to_group_schedule_for_day_of_week_no_permission
  end

  def test_delete_invalid_game
    post "/games/20/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "You don't have permission to do that!"
  end
end
