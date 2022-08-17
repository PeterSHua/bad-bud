# Route helpers
def force_login
  @player_id = session[:player_id]

  if @player_id.nil?
    session[:error] = "You must be logged in to do that."
    redirect "/game_list"
  end
end

def game_have_permission?(game_id)
  if session[:logged_in] && @storage.game_organizer?(game_id, session[:player_id])
    true
  else
    false
  end
end

def check_game_permission(game_id)
  if game_have_permission?(game_id)
    return
  end

  session[:error] = "You don't have permission to do that!"
  redirect "/game_list"
end

def check_group_permission(group_id)
  if group_have_permission?(group_id)
    return
  end

  session[:error] = "You don't have permission to do that!"
  redirect "/group_list"
end

def group_have_permission?(group_id)
  if session[:logged_in] && @storage.group_organizer?(group_id, session[:player_id])
    true
  else
    false
  end
end

def create_game
  game = Game.new(group_id: @group_id,
                  start_time: @start_time,
                  duration: @duration,
                  location: @location,
                  level: @level,
                  fee: @fee,
                  total_slots: @total_slots)

  @storage.create_game(game)
end

def load_game(id)
  game = @storage.find_game(id)
  return game if game

  session[:error] = "The specified game was not found."
  redirect "/game_list"
end

def no_group_selected?
  params[:group_id].empty?
end

def create_group_entry_for_game_without_group
  @group_id = @storage.last_group_id + 1
  group = Group.new(id: @group_id)
  @storage.add_group(group)
  @storage.make_organizer(@group_id, @player_id)
end

def load_group(id)
  group = @storage.find_group(id)
  return group if group

  session[:error] = "The specified group was not found."
  redirect "/group_list"
end

def load_player(id)
  player = @storage.find_player(id)
  return player if player

  session[:error] = "The specified player was not found."
  redirect "/game_list"
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
  status 422
end

def valid_username?
  (4..10).cover?(params[:username].size) && !/[^\w]/.match?(params[:username])
end

def handle_invalid_username
  session[:error] = "Username must consist of only letters and numbers, "\
  "and must be between 4-10 characters."
  status 422
end

def valid_password?
  (4..10).cover?(params[:password].size) && !/\s/.match?(params[:password])
end

def handle_invalid_password
  session[:error] = "Password must be between 4-10 characters and cannot "\
                    "contain spaces."
  status 422
end

def correct_password?
  password = @storage.find_password(params[:username])
  return false if password.nil?

  BCrypt::Password.new(password) == params[:password]
end

def register_acc
  encrypted_password = BCrypt::Password.create(params[:password]).to_s
  player = Player.new(username: params[:username],
                      password: encrypted_password,
                      name: params[:username])
  @storage.add_player(player)

  session[:success] = "Your account has been registered."
  session[:logged_in] = true
  session[:username] = params[:username]
  session[:player_id] = @storage.find_player_id(params[:username])
end

def signup_player(game_id, player_id)
  @storage.rsvp_player(game_id, player_id)

  session[:success] = "Player added to this game."
  redirect "/games/#{@game_id}"
end

def valid_game_id?
  params[:game_id].to_i.to_s == params[:game_id]
end

def handle_invalid_game_id
  session[:error] = "Invalid game."
end

def valid_group_id?
  params[:group_id].to_i.to_s == params[:group_id]
end

def handle_invalid_group_id
  session[:error] = "Invalid group."
end

def valid_location?
  (1..300).cover?(params[:location].length)
end

def handle_invalid_location
  session[:error] = "Location cannot be empty and total length cannot exceed 1000 characters."
  status 422
end

def valid_slots?
  params[:total_slots].to_i.to_s == params[:total_slots] &&
    params[:total_slots].to_i.between?(1, 1000)
end

def handle_invalid_slots
  session[:error] = "Slots must be between 1 and 1000."
  status 422
end

def valid_fee?
  params[:fee].to_i.to_s == params[:fee] &&
    params[:fee].to_i.between?(0, 1000)
end

def handle_invalid_fee
  session[:error] = "Fee must be between 0 and 1000."
  status 422
end

def valid_player_id?
  params[:player_id].to_i.to_s == params[:player_id]
end

def handle_invalid_player_id
  session[:error] = "Invalid player."
end

def valid_player_name?
  (1..20).cover?(params[:player_name].strip.length)
end

def handle_invalid_player_name
  session[:error] = "Your name must be between 1 and 20 characters."
  status 422
end

def valid_group_name
  (1..20).cover?(params[:name].length)
end

def group_exists?
  @storage.group_name_exists?(params[:name])
end

def handle_group_already_exists
  session[:error] = "A group already exists with that name."
  status 422
end

def handle_invalid_group_name
  session[:error] = "Group name must be between 1 and 20 characters."
  status 422
end

def valid_group_about
  params[:about].nil? || (1..300).cover?(params[:about].length)
end

def handle_invalid_group_about
  session[:error] = "Group about max character limit is 300."
  status 422
end

def valid_notes?(notes)
  notes.nil? || notes.length <= 1000
end

def normalize_day(day)
  day += DAYS_OF_WEEK.size
end

def calc_start_time(scheduled_game)
  days_til_game_day_from_publish_day = scheduled_game.start_time.wday - @publish_day

  if days_til_game_day_from_publish_day <= 0
    days_til_game_day_from_publish_day = normalize_day(days_til_game_day_from_publish_day)
  end

  days_til_publish_day = @publish_day - Time.now.wday

  if days_til_publish_day <= 0
    normalize_day(days_til_publish_day)
  end

  game_day = Time.new +
             (days_til_publish_day + days_til_game_day_from_publish_day) * DAY_TO_SEC

  "#{game_day.year}-#{game_day.mon}-#{game_day.day} #{scheduled_game.start_time.hour}"
end

def add_group_schedule_day_of_week_game
  date = case @day_of_week
         when 0 then "2022-07-03"
         when 1 then "2022-07-04"
         when 2 then "2022-07-05"
         when 3 then "2022-07-06"
         when 4 then "2022-07-07"
         when 5 then "2022-07-08"
         when 6 then "2022-07-09"
         end

  game = Game.new(start_time: "#{date} #{params[:hour]}#{params[:am_pm]}",
                  duration: params[:duration].to_i,
                  group_name: @group.name,
                  group_id: @group.id.to_i,
                  location: params[:location],
                  fee: params[:fee].to_i,
                  total_slots: params[:total_slots].to_i,
                  template: true)

  @storage.add_game(game)
end
