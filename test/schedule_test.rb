require_relative "helper"

class BadBudsTest < Minitest::Test
  def test_view_group_schedule
    get "/groups/1/schedule", {}, logged_in_as_david

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Game Notes"
  end

  def test_view_group_schedule_no_permission
    get "/groups/1/schedule"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_view_invalid_group_schedule1
    get "/groups/9/schedule", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_view_invalid_group_schedule2
    get "/groups/abc/schedule", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_view_invalid_group_schedule3
    get "/groups/1abc/schedule", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_edit_group_schedule_notes
    group_notes = {
      notes: "Details"
    }

    post "/groups/1/schedule/edit", group_notes, logged_in_as_david
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Group notes updated."
    assert_includes last_response.body, "Details"
  end

  def test_edit_group_schedule_notes_no_permission
    group_notes = {
      notes: "Details"
    }

    post "/groups/1/schedule/edit", group_notes

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_edit_group_schedule_notes_too_long
    notes = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
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

    group_notes = {
      notes: notes
    }

    post "/groups/1/schedule/edit", group_notes, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Note cannot be greater than 1000 characters."
  end

  def test_view_group_schedule_day_games1
    get "/groups/1/schedule/0", {}, logged_in_as_david

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Sunday"
  end

  def test_view_group_schedule_day_games2
    get "/groups/1/schedule/6", {}, logged_in_as_david

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Saturday"
  end

  def test_view_group_schedule_day_games_no_permission
    get "/groups/1/schedule/0"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_view_invalid_group_schedule_day_games1
    get "/groups/9/schedule/0", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_view_invalid_group_schedule_day_games2
    get "/groups/abc/schedule/0", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_view_invalid_group_schedule_day_games3
    get "/groups/1abc/schedule/0", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_view_group_schedule_invalid_day_games1
    get "/groups/1/schedule/9", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid day of the week.", session[:error]
  end

  def test_view_group_schedule_invalid_day_games2
    get "/groups/1/schedule/abc", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid day of the week.", session[:error]
  end

  def test_view_group_schedule_invalid_day_games3
    get "/groups/1/schedule/1abc", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid day of the week.", session[:error]
  end

  def test_view_add_game_to_group_schedule_for_day_of_week
    get "/groups/1/schedule/0/add", {}, logged_in_as_david

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Novice BM Vancouver"
    assert_includes last_response.body, "Sunday"
  end

  def test_view_add_game_to_group_schedule_for_day_of_week_no_permission
    get "/groups/1/schedule/0/add"

    assert_equal 302, last_response.status
    assert_equal "You must be logged in to do that.", session[:error]
  end

  def test_view_add_game_to_invalid_group_schedule_for_day_of_week1
    get "/groups/9/schedule/0/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_view_add_game_to_invalid_group_schedule_for_day_of_week2
    get "/groups/abc/schedule/0/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_view_add_game_to_invalid_group_schedule_for_day_of_week3
    get "/groups/1abc/schedule/0/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_view_add_game_to_group_schedule_for_invalid_day_of_week1
    get "/groups/1/schedule/9/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid day of the week.", session[:error]
  end

  def test_view_add_game_to_group_schedule_for_invalid_day_of_week2
    get "/groups/1/schedule/abc/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid day of the week.", session[:error]
  end

  def test_view_add_game_to_group_schedule_for_invalid_day_of_week3
    get "/groups/1/schedule/1abc/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid day of the week.", session[:error]
  end

  def test_add_game_to_group_schedule_for_day_of_week
    game_details = {
      group_id: 1,
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backyard',
      level: 'All level',
      total_slots: 9,
      fee: 19
    }

    post "/groups/1/schedule/0/add", game_details, logged_in_as_david
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Added game to schedule."
    assert_includes last_response.body, "My backyard"
  end

  def test_add_game_to_group_schedule_for_day_of_week_no_permission
    game_details = {
      group_id: "",
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backyard',
      level: 'All level',
      total_slots: 9,
      fee: 19
    }

    post "/groups/1/schedule/0/add", game_details

    get last_response["Location"]
    assert_includes last_response.body, "You must be logged in to do that."
    refute_includes last_response.body, "My backyard"
  end

  def test_add_game_to_invalid_group_schedule_for_day_of_week1
    post "/groups/9/schedule/0/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "The specified group was not found.", session[:error]
  end

  def test_add_game_to_invalid_group_schedule_for_day_of_week2
    post "/groups/abc/schedule/0/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_add_game_to_invalid_group_schedule_for_day_of_week3
    post "/groups/1abc/schedule/0/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid group.", session[:error]
  end

  def test_add_game_to_group_schedule_for_invalid_day_of_week1
    post "/groups/1/schedule/9/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid day of the week.", session[:error]
  end

  def test_add_game_to_group_schedule_for_invalid_day_of_week2
    post "/groups/1/schedule/abc/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid day of the week.", session[:error]
  end

  def test_add_game_to_group_schedule_for_invalid_day_of_week3
    post "/groups/1/schedule/1abc/add", {}, logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "Invalid day of the week.", session[:error]
  end

  def test_add_game_to_group_schedule_for_day_of_week_location_too_short
    game_details = {
      group_id: 1,
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: '',
      level: 'All level',
      total_slots: 9,
      fee: 19
    }

    post "/groups/1/schedule/1/add", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Location cannot be empty and total length cannot exceed 1000 characters."
  end

  def test_add_game_to_group_schedule_for_day_of_week_location_too_long
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
      level: 'All level',
      total_slots: 9,
      fee: 19
    }

    post "/groups/1/schedule/1/add", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Location cannot be empty and total length cannot exceed 1000 characters."
  end

  def test_add_game_to_group_schedule_for_day_of_week_level_too_short
    game_details = {
      group_id: 1,
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backyard',
      level: '',
      total_slots: 9,
      fee: 19
    }

    post "/groups/1/schedule/1/add", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Level cannot be empty and total length cannot exceed 300 characters."
    refute_includes last_response.body, "Badminton Vancouver"
  end

  def test_add_game_to_group_schedule_for_day_of_week_level_too_long
    level = "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"\
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
      location: 'My backyard',
      level: level,
      total_slots: 9,
      fee: 19
    }

    post "/groups/1/schedule/1/add", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Level cannot be empty and total length cannot exceed 300 characters."
    refute_includes last_response.body, "Badminton Vancouver"
  end

  def test_add_game_to_group_schedule_for_day_of_week_invalid_slots
    game_details = {
      group_id: 1,
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      level: 'All level',
      total_slots: 'abc',
      fee: 19
    }

    post "/groups/1/schedule/1/add", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Slots must be between 1 and 1000."
  end

  def test_add_game_to_group_schedule_for_day_of_week_slots_too_small
    game_details = {
      group_id: 1,
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      level: 'All level',
      total_slots: 0,
      fee: 19
    }

    post "/groups/1/schedule/1/add", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Slots must be between 1 and 1000."
  end

  def test_add_game_to_group_schedule_for_day_of_week_slots_too_large
    game_details = {
      group_id: 1,
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      level: 'All level',
      total_slots: 1001,
      fee: 19
    }

    post "/groups/1/schedule/1/add", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Slots must be between 1 and 1000."
  end

  def test_add_game_to_group_schedule_for_day_of_week_invalid_fee
    game_details = {
      group_id: 1,
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      level: 'All level',
      total_slots: 9,
      fee: 'abc'
    }

    post "/groups/1/schedule/1/add", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Fee must be between 0 and 1000."
  end

  def test_add_game_to_group_schedule_for_day_of_week_fee_too_large
    game_details = {
      group_id: 1,
      date: "2022/8/15",
      hour: 1,
      am_pm: 'am',
      duration: 4,
      location: 'My backard',
      level: 'All level',
      total_slots: 9,
      fee: 1001
    }

    post "/groups/1/schedule/1/add", game_details, logged_in_as_david
    assert_equal 422, last_response.status

    assert_includes last_response.body, "Fee must be between 0 and 1000."
  end
end
