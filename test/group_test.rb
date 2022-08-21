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
    assert_equal "Group was created.", session[:success]

    get last_response["Location"]
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

    flash_msg = "Group name must be between 1 and 50 characters."

    assert_includes last_response.body, flash_msg
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

    flash_msg = "Group name must be between 1 and 50 characters."

    assert_includes last_response.body, flash_msg
  end

  def test_create_group_long_about
    about = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

    group_details = {
      name: 'A new group',
      about: about
    }

    post "/groups/create", group_details, logged_in_as_david
    assert_equal 422, last_response.status

    flash_msg = "Group about max character limit is 1000."
    assert_includes last_response.body, flash_msg
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
    assert_equal "Invalid group.", session[:error]
  end

  def test_view_invalid_group3
    get "/groups/9abc"

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_view_edit_group
    get "/groups/1/edit", {}, logged_in_as_david

    assert_equal 200, last_response.status
  end

  def test_edit_group
    group_details = {
      name: 'A new group',
      about: 'Details of the new group'
    }

    post "/groups/1/edit", group_details, logged_in_as_david
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Group updated."
    assert_includes last_response.body, "A new group"
    assert_includes last_response.body, "Details of the new group"
  end

  def test_edit_group_no_permission
    group_details = {
      name: 'A new group',
      about: 'Details of the new group'
    }

    post "/groups/1/edit", group_details

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]

    get last_response["Location"]
    refute_includes last_response.body, "A new group"
    refute_includes last_response.body, "Details of the new group"
  end

  def test_edit_group_short_name
    group_details = {
      name: '',
      about: 'Details of the new group'
    }

    post "/groups/1/edit", group_details, logged_in_as_david
    assert_equal 422, last_response.status

    flash_msg = "Group name must be between 1 and 50 characters."
    assert_includes last_response.body, flash_msg
  end

  def test_edit_group_long_name
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

    post "/groups/1/edit", group_details, logged_in_as_david
    assert_equal 422, last_response.status

    flash_msg = "Group name must be between 1 and 50 characters."
    assert_includes last_response.body, flash_msg
  end

  def test_edit_group_long_about
    about = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
            "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

    group_details = {
      name: 'A new group',
      about: about
    }

    post "/groups/1/edit", group_details, logged_in_as_david
    assert_equal 422, last_response.status

    flash_msg = "Group about max character limit is 1000."
    assert_includes last_response.body, flash_msg
  end

  def test_edit_invalid_group1
    post "/groups/9/edit", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_edit_invalid_group2
    post "/groups/abc/edit", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_edit_invalid_group3
    post "/groups/9abc/edit", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_delete_group
    post "/groups/1/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "Group has been deleted."

    refute_includes last_response.body, "Novice BM Vancouver"
  end

  def test_delete_group_no_permission
    post "/groups/1/delete"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_delete_invalid_group1
    post "/groups/20/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "The specified group was not found."
  end

  def test_delete_invalid_group2
    post "/groups/abc/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "Invalid group."
  end

  def test_delete_invalid_group3
    post "/groups/20abc/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "Invalid group."
  end

  def test_join_group
    post "/groups/2/join", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Joined group.", session[:success]
  end

  def test_join_group_no_permission
    post "/groups/1/join"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_join_invalid_group1
    post "/groups/9/join", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_join_invalid_group2
    post "/groups/abc/join", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_join_invalid_group3
    post "/groups/1abc/join", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_left_group
    post "/groups/2/leave", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Left group.", session[:success]
  end

  def test_left_group_no_permission
    post "/groups/1/leave"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_left_invalid_group1
    post "/groups/9/leave", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_left_invalid_group2
    post "/groups/9/leave", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_left_invalid_group3
    post "/groups/9/leave", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end
end
