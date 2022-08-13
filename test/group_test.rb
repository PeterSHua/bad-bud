class BadBudsTest < Minitest::Test
  def test_view_create_group
    skip
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

  def test_view_group
    get "/groups/1"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Monday, Jul 25"
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "3 / 18"
  end

  def test_view_invalid_group1
    get "/groups/9"

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_view_invalid_group2
    get "/groups/abc"

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_view_invalid_group3
    get "/groups/9abc"

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_view_edit_group

  end

  def test_edit_group

  end

  def test_edit_group_no_permission

  end

  def test_edit_group_already_exists
    skip
  end

  def test_edit_group_short_name
    skip
  end

  def test_edit_group_long_name
    skip
  end

  def test_edit_group_invalid_chars_name
    skip
  end

  def test_edit_group_long_about
    skip
  end

  def test_edit_invalid_group1
    skip
  end

  def test_edit_invalid_group2
    skip
  end

  def test_edit_invalid_group3
    skip
  end

  def test_delete_group
    skip
  end

  def test_delete_group_no_permission
    skip
  end

  def test_delete_invalid_group1
    skip
  end

  def test_delete_invalid_group2
    skip
  end

  def test_delete_invalid_group3
    skip
  end
end
