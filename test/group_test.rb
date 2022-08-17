require_relative "helper"

class BadBudsTest < Minitest::Test
  def test_view_create_group
    get "/groups/create", {}, logged_in_as_david

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Create Group"
  end

  def test_view_create_group_no_permission
    get "/groups/create"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_create_group
    group_details = {
      name: 'A new group',
      about: 'Details of the new group'
    }

    post "/groups/create", group_details, logged_in_as_david
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Group was created."
    assert_includes last_response.body, "A new group"
    assert_includes last_response.body, "Details of the new group"
  end

  def test_create_group_no_permission
    group_details = {
      name: 'A new group',
      about: 'Details of the new group'
    }

    post "/groups/create", group_details

    get last_response["Location"]
    assert_includes last_response.body, "You must be logged in to do that."
    refute_includes last_response.body, "A new group"
  end

  def test_create_group_already_exists
    group_details = {
      name: 'Novice BM Vancouver',
      about: 'Details of the new group'
    }

    post "/groups/create", group_details, logged_in_as_david
    
    assert_includes last_response.body, "A group already exists with that name."
  end

  def test_create_group_short_name
    group_details = {
      name: '',
      about: 'Details of the new group'
    }

    post "/groups/create", group_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Group name must be between 1 and 20 characters."
  end

  def test_create_group_long_name
    name = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
           "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
           "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
           "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
           "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
           "zzzzzz"

    group_details = {
      name: name,
      about: 'Details of the new group'
    }

    post "/groups/create", group_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Group name must be between 1 and 20 characters."
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
    get "/groups/1/edit", {}, logged_in_as_david

    assert_equal 200, last_response.status
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
