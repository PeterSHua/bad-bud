require_relative "helper"

class BadBudsTest < Minitest::Test
  def test_view_create_game
    get "/games/create", {}, logged_in_as_david

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Create Game"
  end

  def test_view_create_game_no_permission
    get "/games/create"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_create_game_for_group
    game_details = {
      group_id: 1,
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backyard',
      total_slots: 9,
      fee: 19
    }

    post "/games/create", game_details, logged_in_as_david
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Game was created."
    assert_includes last_response.body, "My backyard"
  end

  def test_create_game_no_group
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backyard',
      total_slots: 9,
      fee: 19
    }

    post "/games/create", game_details, logged_in_as_david
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Game was created."
    assert_includes last_response.body, "My backyard"
  end

  def test_create_game_no_permission
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backyard',
      total_slots: 9,
      fee: 19
    }

    post "/games/create", game_details

    get last_response["Location"]
    assert_includes last_response.body, "You must be logged in to do that."
    refute_includes last_response.body, "My backyard"
  end

  def test_create_game_location_too_short
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: '',
      total_slots: 9,
      fee: 19
    }

    post "/games/create", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Location cannot be empty and total length cannot exceed 1000 characters."
    refute_includes last_response.body, "My backyard"
  end

  def test_create_game_location_too_long
    location = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
               "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
               "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
               "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
               "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
               "zzzzzz"

    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: location,
      total_slots: 9,
      fee: 19
    }

    post "/games/create", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Location cannot be empty and total length cannot exceed 1000 characters."
    refute_includes last_response.body, "My backyard"
  end

  def test_create_game_invalid_slots
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      total_slots: 'abc',
      fee: 19
    }

    post "/games/create", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Slots must be between 1 and 1000."
  end

  def test_create_game_slots_too_high
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      total_slots: 1001,
      fee: 19
    }

    post "/games/create", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Slots must be between 1 and 1000."
  end

  def test_create_game_invalid_fee
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      total_slots: 9,
      fee: 'abc'
    }

    post "/games/create", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Fee must be between 0 and 1000."
  end

  def test_create_game_fee_too_high
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      total_slots: 9,
      fee: 1001
    }

    post "/games/create", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Fee must be between 0 and 1000."
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

  def test_view_edit_game
    get "/games/1/edit", {}, logged_in_as_david

    assert_equal 200, last_response.status
  end

  def test_view_edit_invalid_game
    get "/games/15/edit", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "You don't have permission to do that!", session[:error]
  end

  def test_edit_game
    game_details = {
      group_id: 1,
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backyard',
      total_slots: 9,
      fee: 19
    }

    post "/games/1/edit", game_details, logged_in_as_david
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Game was updated."
    assert_includes last_response.body, "My backyard"
    assert_includes last_response.body, "Aug 15"
    assert_includes last_response.body, "1:00AM"
    assert_includes last_response.body, "5:00AM"
    assert_includes last_response.body, "/ 9"
    assert_includes last_response.body, "$19"
  end

  def test_edit_game_no_permission
    get "/games/1/edit"

    assert_equal 302, last_response.status
    assert_equal "You don't have permission to do that!", session[:error]
  end

  def test_edit_invalid_game
    post "/games/15/edit", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "You don't have permission to do that!", session[:error]
  end

  def test_edit_game_location_too_short
    game_details = {
      group_id: 1,
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: '',
      total_slots: 9,
      fee: 19
    }

    post "/games/1/edit", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Location cannot be empty and total length cannot exceed 1000 characters."
    refute_includes last_response.body, "Badminton Vancouver"
  end

  def test_edit_game_location_too_long
    location = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
               "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
               "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
               "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
               "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
               "zzzzzz"

    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: location,
      total_slots: 9,
      fee: 19
    }

    post "/games/1/edit", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Location cannot be empty and total length cannot exceed 1000 characters."
    refute_includes last_response.body, "Badminton Vancouver"
  end

  def test_edit_game_invalid_slots
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      total_slots: 'abc',
      fee: 19
    }

    post "/games/1/edit", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Slots must be between 1 and 1000."
  end

  def test_edit_game_slots_too_high
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      total_slots: 1001,
      fee: 19
    }

    post "/games/create", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Slots must be between 1 and 1000."
  end

  def test_edit_game_invalid_fee
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      total_slots: 9,
      fee: 'abc'
    }

    post "/games/1/edit", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Fee must be between 0 and 1000."
  end

  def test_edit_game_fee_too_high
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      total_slots: 9,
      fee: 1001
    }

    post "/games/1/edit", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Fee must be between 0 and 1000."
  end

  def test_delete_game
    post "/games/1/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "Game has been deleted."

    refute_includes last_response.body, "Monday, Jul 25"
  end

  def test_delete_game_no_permission
    post "/games/1/delete"

    assert_equal 302, last_response.status
    assert_equal "You don't have permission to do that!", session[:error]
  end

  def test_delete_invalid_game
    post "/games/20/delete", {}, logged_in_as_david

    get last_response["Location"]
    assert_includes last_response.body, "You don't have permission to do that!"
  end
end
