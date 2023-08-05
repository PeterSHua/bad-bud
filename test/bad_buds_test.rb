require_relative "helper"

class BadBudTest < Minitest::Test
  def test_view_game_list
    get "/game_list"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Monday, Jul 25"
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Badminton Vancouver"
    assert_includes last_response.body, "3 / 18"
  end

  def test_view_group_list
    get "/group_list"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Beginner/intermediate games every week"
  end
end
