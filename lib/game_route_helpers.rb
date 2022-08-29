def game_have_permission?
  session[:logged_in] && @storage.game_organizer?(@game_id, session[:player_id])
end

def handle_no_game_permission
  session[:error] = "You don't have permission to do that!"
end

def game_have_open_slots?
  @game.filled_slots >= @game.total_slots
end

def handle_game_no_open_slots
  session[:error] = "Sorry, no empty slots remaining."
end

def valid_game_id?
  params[:game_id].to_i.to_s == params[:game_id]
end

def handle_invalid_game_id
  session[:error] = "Invalid game."
end

def handle_game_not_found
  session[:error] = "The specified game was not found."
end

def valid_location?
  location_range = Game::MIN_LOCATION_LEN..Game::MAX_LOCATION_LEN
  (location_range).cover?(params[:location]&.length)
end

def handle_invalid_location
  session[:error] = "Location cannot be empty and total length cannot exceed "\
                    "#{Game::MAX_LOCATION_LEN} characters."
end

def valid_level?
  level_range = Game::MIN_LEVEL_LEN..Game::MAX_LEVEL_LEN
  (level_range).cover?(params[:level]&.length)
end

def handle_invalid_level
  session[:error] = "Level cannot be empty and total length cannot exceed "\
                    "#{Game::MAX_LEVEL_LEN} characters."
end

def valid_slots?
  params[:total_slots].to_i.to_s == params[:total_slots] &&
    params[:total_slots].to_i.between?(Game::MIN_SLOTS, Game::MAX_SLOTS)
end

def handle_invalid_slots
  session[:error] = "Slots must be between #{Game::MIN_SLOTS} "\
                    "and #{Game::MAX_SLOTS}."
end

def valid_fee?
  params[:fee].to_i.to_s == params[:fee] &&
    params[:fee].to_i.between?(Game::MIN_FEE, Game::MAX_FEE)
end

def handle_invalid_fee
  session[:error] = "Fee must be between #{Game::MIN_FEE} "\
                    "and #{Game::MAX_FEE}."
end

def valid_game_notes?
  note_range = Game::MIN_NOTE_LEN..Game::MAX_NOTE_LEN
  params[:notes].nil? || (note_range).cover?(params[:notes].length)
end

def handle_invalid_game_notes
  session[:error] = "Note cannot be greater than #{Game::MAX_NOTE_LEN} "\
                    "characters."
end

def valid_group_name?
  (Group::MIN_NAME_LEN..Group::MAX_NAME_LEN).cover?(params[:name]&.length)
end

def handle_invalid_group_name
  session[:error] = "Group name must be between #{Group::MIN_NAME_LEN} " \
                    "and #{Group::MAX_NAME_LEN} characters."
end

def group_exists?
  @storage.group_name_exists?(params[:name])
end

def handle_group_already_exists
  session[:error] = "A group already exists with that name."
end

def valid_group_about?
  about_range = Group::MIN_ABOUT_LEN..Group::MAX_ABOUT_LEN
  params[:about].nil? || (about_range).cover?(params[:about].length)
end

def handle_invalid_group_about
  session[:error] = "Group about max character limit is "\
                    "#{Group::MAX_ABOUT_LEN}."
end

def valid_group_notes?
  note_range = Group::MIN_SCHEDULE_NOTES..Group::MAX_SCHEDULE_NOTES
  params[:notes].nil? || (note_range).cover?(params[:notes].length)
end

def handle_invalid_group_notes
  session[:error] = "Note cannot be greater than "\
                    "#{Group::MAX_SCHEDULE_NOTES} characters."
end

def error_for_create_game
  if !valid_location?
    handle_invalid_location
  elsif !valid_level?
    handle_invalid_level
  elsif !valid_slots?
    handle_invalid_slots
  elsif !valid_fee?
    handle_invalid_fee
  end
end

def error_for_view_edit_game
  if !valid_game_id?
    handle_invalid_game_id
  elsif !game_have_permission?
    handle_no_game_permission
  elsif !@game.id
    handle_game_not_found
  end
end

def error_for_view_game
  if !valid_game_id?
    handle_invalid_game_id
  elsif !@game.id
    handle_game_not_found
  end
end

def url_error_for_edit_game
  if !valid_game_id?
    handle_invalid_game_id
  elsif !@game.id
    handle_game_not_found
  end
end

def input_error_for_edit_game
  if !valid_location?
    handle_invalid_location
  elsif !valid_level?
    handle_invalid_level
  elsif !valid_slots?
    handle_invalid_slots
  elsif !valid_fee?
    handle_invalid_fee
  elsif !valid_game_notes?
    handle_invalid_game_notes
  end
end

def error_for_delete_game
  if !valid_game_id?
    handle_invalid_game_id
  elsif !@game.id
    handle_game_not_found
  elsif !game_have_permission?
    handle_no_game_permission
  end
end

def game_url_error_for_player_confirm_payment_in_game
  if !valid_game_id?
    handle_invalid_game_id
  elsif !@game.id
    handle_game_not_found
  elsif !game_have_permission?
    handle_no_game_permission
  end
end

def player_url_error_for_player_confirm_payment_in_game
  if !valid_player_id?
    handle_invalid_player_id
  elsif !@player.id
    handle_player_not_found
  end
end

def url_error_for_add_anon_player_to_game
  if !valid_game_id?
    handle_invalid_game_id
  elsif !@game.id
    handle_game_not_found
  end
end

def input_error_for_add_anon_player_to_game
  if !valid_player_name?
    handle_invalid_player_name
  elsif game_have_open_slots?
    handle_game_no_open_slots
  elsif player_already_signed_up?
    handle_player_already_signed_up
  end
end

def game_url_error_for_player_rsvp_in_game
  if !valid_game_id?
    handle_invalid_game_id
  elsif !@game.id
    handle_game_not_found
  end
end

def player_url_error_for_player_rsvp_in_game
  if !valid_player_id?
    handle_invalid_player_id
  elsif !@player.id
    handle_player_not_found
  end
end

def input_error_for_add_reg_player_to_game
  if game_have_open_slots?
    handle_game_no_open_slots
  elsif player_already_signed_up?
    handle_player_already_signed_up
  end
end
