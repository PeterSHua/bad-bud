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
    get "/players/2/edit", {}, logged_in_as_david

    assert_equal 200, last_response.status
  end

  def test_view_edit_player_no_permission
    get "/players/2/edit"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_view_edit_invalid_player1
    get "/players/9/edit", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified player was not found.", session[:error]
  end

  def test_view_edit_invalid_player2
    get "/players/abc/edit", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_view_edit_invalid_player3
    get "/players/1abc/edit", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_edit_player
    player_info = {
      name: 'John Doe',
      rating: 4,
      about: 'About me',
      password: 'zxc456'
    }

    post "/players/2/edit", player_info, logged_in_as_david

    assert_equal 302, last_response.status
    get last_response["Location"]
    assert_includes last_response.body, "Player updated."
    assert_includes last_response.body, "John Doe"
    assert_includes last_response.body, "About me"
    assert_includes last_response.body, "Rating:</a> 4"

    post "/logout"

    login_info = {
      username: 'david',
      password: 'zxc456'
    }

    post "/login", login_info
    assert_equal 302, last_response.status
    assert_equal "Welcome!", session[:success]
  end

  def test_edit_player_no_permission
    post "/players/2/edit"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_edit_invalid_player1
    post "/players/9/edit", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified player was not found.", session[:error]
  end

  def test_edit_invalid_player2
    post "/players/abc/edit", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_edit_invalid_player3
    post "/players/1abc/edit", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end
end
