require_relative "helper"

class BadBudsTest < Minitest::Test
  def test_view_player
    get "/players/2"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "David C"
    assert_includes last_response.body, "Rating:</a> 3"
    assert_includes last_response.body, "Founder of Novice BM Vancouver"
  end

  def test_view_invalid_player1
    get "/players/9"

    assert_equal 302, last_response.status
    assert_equal "The specified player was not found.", session[:error]
  end

  def test_view_invalid_player2
    get "/players/abc"

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_view_invalid_player3
    get "/players/1abc"

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_view_edit_player

  end

  def test_view_edit_player_no_permission

  end

  def test_view_edit_invalid_player1

  end

  def test_view_edit_invalid_player2

  end

  def test_view_edit_invalid_player3

  end

  def test_edit_player_no_permission

  end

  def test_edit_invalid_player1

  end

  def test_edit_invalid_player2

  end

  def test_edit_invalid_player3

  end
end
