require_relative "helper"

class BadBudsTest < Minitest::Test
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
    skip
  end

  def test_promote_invalid_player2
    skip
  end

  def test_promote_invalid_player3
    skip
  end

  def test_demote_player
    skip
  end

  def test_demote_player_no_permission
    skip
  end

  def test_demote_invalid_player1
    skip
  end

  def test_demote_invalid_player2
    skip
  end

  def test_demote_invalid_player3
    skip
  end

  def test_remove_player
    skip
  end

  def test_remove_player_no_permission
    skip
  end

  def test_remove_invalid_player1
    skip
  end

  def test_remove_invalid_player2
    skip
  end

  def test_remove_invalid_player3
    skip
  end
end
