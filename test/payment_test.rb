require_relative "helper"

class BadBudsTest < Minitest::Test
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

  def test_confirm_payment_game_not_found
    post "/games/15/players/1/confirm_paid", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified game was not found.", session[:error]
  end

  def test_confirm_payment_invalid_game1
    post "/games/abc/players/1/confirm_paid", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid game.", session[:error]
  end

  def test_confirm_payment_invalid_game2
    post "/games/1abc/players/1/confirm_paid", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid game.", session[:error]
  end

  def test_confirm_payment_player_not_signed_up

  end

  def test_confirm_payment_invalid_player1
    post "/games/1/players/9/confirm_paid", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified player was not found.", session[:error]
  end

  def test_confirm_payment_invalid_player2
    post "/games/1/players/abc/confirm_paid", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
  end

  def test_confirm_payment_invalid_player3
    post "/games/1/players/1abc/confirm_paid", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid player.", session[:error]
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
    skip
  end
end
