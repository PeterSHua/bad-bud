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

def player_have_permission?
  session[:player_id].to_i == @player_id
end

def handle_player_no_permission
  session[:error] = "You don't have permission to do that!"
end

def player_already_signed_up?
  @storage.already_signed_up?(@game_id, @player_id)
end

def handle_player_already_signed_up
  session[:error] = "Player already signed up!"
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

def handle_player_not_found
  session[:error] = "The specified player was not found."
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
