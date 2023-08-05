require_relative "helper"

class BadBudTest < Minitest::Test
  def test_promote_player
    post "/groups/1/players/1/promote", {}, logged_in_as_david

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Player promoted."
  end

  def test_promote_player_no_permission
    post "/groups/1/players/1/promote"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_promote_invalid_player1
    post "/groups/1/players/15/promote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified player was not found.", session[:error]
  end

  def test_promote_invalid_player2
    post "/groups/1/players/abc/promote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_promote_invalid_player3
    post "/groups/1/players/1abc/promote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_promote_invalid_group1
    post "/groups/9/players/1/promote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_promote_invalid_group2
    post "/groups/abc/players/1/promote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_promote_invalid_group3
    post "/groups/1abc/players/1/promote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_demote_player
    post "/groups/1/players/1/promote", {}, logged_in_as_david
    get last_response["Location"]

    post "/groups/1/players/1/demote"

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Player demoted."
  end

  def test_demote_player_no_permission
    post "/groups/1/players/1/demote"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_demote_invalid_player1
    post "/groups/1/players/15/demote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified player was not found.", session[:error]
  end

  def test_demote_invalid_player2
    post "/groups/1/players/abc/demote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_demote_invalid_player3
    post "/groups/1/players/1abc/promote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_demote_invalid_group1
    post "/groups/9/players/1/demote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_demote_invalid_group2
    post "/groups/abc/players/1/demote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_demote_invalid_group3
    post "/groups/1abc/players/1/demote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_demote_sole_organizer
    post "/groups/1/players/2/demote", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Can't demote the sole organizer.", session[:error]
  end

  def test_remove_player_from_group
    post "/groups/1/players/1/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Player removed."
  end

  def test_remove_player_from_group_no_permission
    post "/groups/1/players/1/remove"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_remove_invalid_player_from_group1
    post "/groups/1/players/15/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified player was not found.", session[:error]
  end

  def test_remove_invalid_player_from_group2
    post "/groups/1/players/abc/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_remove_invalid_player_from_group3
    post "/groups/1/players/1abc/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_remove_player_from_invalid_group1
    post "/groups/9/players/1/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_remove_player_from_invalid_group2
    post "/groups/abc/players/1/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_remove_player_from_invalid_group3
    post "/groups/1abc/players/1/remove", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end
end
