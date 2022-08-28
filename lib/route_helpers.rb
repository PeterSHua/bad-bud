def https_required
  return unless settings.production? && request.scheme == 'http'

  headers['Location'] = request.url.sub('http', 'https')
  halt 301
end

def force_login
  return unless !already_logged_in?

  session[:error] = "You must be logged in to do that."
  redirect "/game_list"
end

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

def player_already_signed_up?
  @storage.already_signed_up?(@game_id, @player_id)
end

def handle_player_already_signed_up
  session[:error] = "Player already signed up!"
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

def assign_view_game_params
  @game_id = params[:game_id].to_i
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

def url_error_for_group_need_permission
  if !valid_group_id?
    handle_invalid_group_id
  elsif !@group.id
    handle_group_not_found
  elsif !group_have_permission?
    handle_group_no_permission
  end
end

def url_error_for_schedule_day
  if !valid_schedule_day?
    handle_invalid_schedule_day
  end
end


def input_error_for_post_schedule
  if !valid_schedule_day?
    handle_invalid_schedule_day
  end
end

def player_url_error_no_permission
  if !valid_player_id?
    handle_invalid_player_id
  elsif !@player.id
    handle_player_not_found
  end
end

def player_url_error_need_permission
  if !valid_player_id?
    handle_invalid_player_id
  elsif !@player.id
    handle_player_not_found
  elsif !player_have_permission?
    handle_player_no_permission
  end
end

def input_error_for_edit_player
  if !valid_player_name?
    handle_invalid_player_name
  elsif !valid_player_rating?
    handle_invalid_player_rating
  elsif !valid_player_about?
    handle_invalid_player_about
  elsif !params[:password].empty? && !valid_password?
    handle_invalid_password
  end
end

def error_for_group_no_permission
  if !valid_group_id?
    handle_invalid_group_id
  elsif !@group.id
    handle_group_not_found
  end
end

def error_for_edit_group
  if !valid_group_id?
    handle_invalid_group_id
  elsif !@group.id
    handle_group_not_found
  elsif !group_have_permission?
    handle_group_no_permission
  end
end

def input_error_for_group
  if !valid_group_name?
    handle_invalid_group_name
  elsif group_exists?
    handle_group_already_exists
  elsif !valid_group_about?
    handle_invalid_group_about
  end
end

def input_error_for_edit_group
  if !valid_group_name?
    handle_invalid_group_name
  elsif !valid_group_about?
    handle_invalid_group_about
  end
end

def input_error_for_group_schedule
  if !valid_group_notes?
    handle_invalid_group_notes
  end
end

def error_for_login
  if !valid_password?
    handle_invalid_password
  elsif !correct_password?
    handle_incorrect_password
  end
end

def url_error_for_register
  return unless already_logged_in?

  handle_already_logged_in
end

def input_error_for_register
  if !valid_username?
    handle_invalid_username
  elsif !valid_password?
    handle_invalid_password
  elsif acc_exists?
    handle_acc_exists
  end
end

def no_group_selected?
  params[:group_id].empty?
end

def create_group_entry_for_game_without_group
  @group_id = @storage.last_group_id + 1
  group = Group.new(id: @group_id)

  group.create(@storage)

  @storage.add_organizer(@group_id, @player_id)
end

def already_logged_in?
  session[:logged_in]
end

def handle_not_logged_in
  session[:error] = "You must be logged in to do that."
end

def handle_already_logged_in
  session[:error] = "You're already logged in."
end

def acc_exists?
  !@storage.find_player_id(params[:username]).nil?
end

def handle_acc_exists
  session[:error] = "That account name already exists."
end

def valid_username?
  username_range = Player::MIN_USERNAME_LEN..Player::MAX_USERNAME_LEN

  (username_range).cover?(params[:username]&.size) &&
    !/[^\w]/.match?(params[:username])
end

def handle_invalid_username
  session[:error] = "Username must consist of only letters and numbers, "\
                    "and must be between #{Player::MIN_USERNAME_LEN}-"\
                    "#{Player::MAX_USERNAME_LEN} characters."
end

def valid_password?
  password_range = Player::MIN_PASS_LEN..Player::MAX_PASS_LEN

  (password_range).cover?(params[:password]&.size) &&
                          !/\s/.match?(params[:password])
end

def handle_invalid_password
  session[:error] = "Password must be between #{Player::MIN_PASS_LEN}"\
                    "-#{Player::MAX_PASS_LEN} characters and cannot "\
                    "contain spaces."
end

def handle_incorrect_password
  session[:error] = "Invalid credentials."
end

def correct_password?
  password = @storage.find_password(params[:username])
  return false if password.nil?

  BCrypt::Password.new(password) == params[:password]
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

def handle_player_not_found
  session[:error] = "The specified player was not found."
end

def valid_group_id?
  params[:group_id].to_i.to_s == params[:group_id]
end

def handle_invalid_group_id
  session[:error] = "Invalid group."
end

def handle_group_not_found
  session[:error] = "The specified group was not found."
end

def group_have_permission?
  session[:logged_in] &&
    @storage.group_organizer?(@group_id, session[:player_id])
end

def handle_group_no_permission
  session[:error] = "You don't have permission to do that!"
end

def valid_schedule_day?
  params[:day_of_week].to_i.to_s == params[:day_of_week] &&
    (0...TimeDate::DAYS_OF_WEEK.size).cover?(params[:day_of_week].to_i)
end

def handle_invalid_schedule_day
  session[:error] = "Invalid day of the week."
end

def player_have_permission?
  session[:player_id].to_i == @player_id
end

def handle_player_no_permission
  session[:error] = "You don't have permission to do that!"
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

def valid_player_id?
  params[:player_id].to_i.to_s == params[:player_id]
end

def handle_invalid_player_id
  session[:error] = "Invalid player."
end

def valid_player_name?
  name_range = Player::MIN_NAME_LEN..Player::MAX_NAME_LEN
  (name_range).cover?(params[:name]&.strip&.length)
end

def handle_invalid_player_name
  session[:error] = "Your name must be between #{Player::MIN_NAME_LEN} and "\
                    "#{Player::MAX_NAME_LEN} characters."
end

def valid_player_rating?
  params[:rating].to_i.to_s == params[:rating] &&
    params[:rating].to_i.between?(Player::MIN_RATING, Player::MAX_RATING)
end

def handle_invalid_player_rating
  session[:error] = "Invalid player rating!"
end

def valid_player_about?
  (0..Player::MAX_ABOUT_LEN).cover?(params[:about]&.length)
end

def handle_invalid_player_about
  session[:error] = "About cannot exceed #{Player::MAX_ABOUT_LEN} characters."
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

def day_of_week_to_date(day)
  case day
  when 0 then TimeDate::SUN_DATE
  when 1 then TimeDate::MON_DATE
  when 2 then TimeDate::TUES_DATE
  when 3 then TimeDate::WED_DATE
  when 4 then TimeDate::THURS_DATE
  when 5 then TimeDate::FRI_DATE
  when 6 then TimeDate::SAT_DATE
  end
end

def normalize_day(day)
  day + TimeDate::DAYS_OF_WEEK.size
end

def calc_start_time(scheduled_game)
  days_btwn_publish_game = scheduled_game.start_time.wday - @day_of_week

  if days_btwn_publish_game <= 0
    days_btwn_publish_game = normalize_day(days_btwn_publish_game)
  end

  days_til_publish = @day_of_week - Time.now.wday

  if days_til_publish <= 0
    days_til_publish = normalize_day(days_til_publish)
  end

  game_day = Time.new +
             (days_til_publish + days_btwn_publish_game) * TimeDate::DAY_TO_SEC

  "#{game_day.year}-#{game_day.mon}-#{game_day.day} "\
  "#{scheduled_game.start_time.hour}"
end
