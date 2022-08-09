require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "bcrypt"

require_relative "lib/database_persistence"
require_relative "lib/game.rb"
require_relative "lib/group.rb"
require_relative "lib/player.rb"

configure do
  enable :sessions
  set :session_secret, "secret" # fix
  set :erb, escape_html: true
end

configure(:development) do
  require "sinatra/reloader" if development?
  also_reload "lib/*.rb"
end

helpers do
  # Fix - remove
  def already_signed_up?(game_id, player_id)
    @storage.already_signed_up?(game_id, player_id)
  end

  def game_organizer?(game_id, player_id)
    @storage.game_organizer?(game_id, player_id)
  end

  def group_organizer?(group_id, player_id)
    @storage.group_organizer?(group_id, player_id)
  end

  def day_of_week_to_name(day_of_week)
    DAYS_OF_WEEK[day_of_week]
  end

  def display_time(game)
    "#{game.start_time.strftime("%l:%M%p")} - #{(game.start_time + game.duration * 60 * 60).strftime("%l:%M%p")}"
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
    session[:error] = "You don't have permission to do that!"
    redirect "/group_list"
  end
end

def group_have_permission?(group_id)
  if session[:logged_in] && @storage.group_organizer?(group_id, session[:player_id])
    true
  else
    false
  end
end

def valid_password?(password)
  (4..10).cover?(password.size) && !/\s/.match?(password)
end

def correct_password?(username, raw_password)
  password = @storage.find_password(username)

  return false if password.nil?

  BCrypt::Password.new(password) == raw_password
end

def load_game(id)
  game = @storage.find_game(id)
  return game if game

  session[:error] = "The specified game was not found."
  redirect "/game_list"
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

def error_for_player_name(name)
  if !(1..20).cover? name.size
    "Your name must be between 1 and 20 characters."
  end
end

def acc_exists?(username)
  !@storage.find_player_id(username).nil?
end

def valid_username?(username)
  (4..10).cover?(username.size) && !/[^\w]/.match?(username)
end

def valid_password?(password)
  (4..10).cover?(password.size) && !/\s/.match?(password)
end

def register_acc(username, password)
  encrypted_password = BCrypt::Password.create(password).to_s
  player = Player.new(username: username,
                      password: encrypted_password,
                      name: username)
  @storage.add_player(player)
end

def signup_player(game_id, player_id)
  @storage.rsvp_player(game_id, player_id)

  session[:success] = "Player added to this game."
  redirect "/games/#{@game_id}"
end

def signup_anon_player(game_id, player_name)
  error = error_for_player_name(player_name)

  if error
    session[:error] = error

    status 422
    erb :game, layout: :layout
  else
    @storage.rsvp_anon_player(game_id, player_name)

    session[:success] = "Player has been signed up."
    redirect "/games/#{game_id}"
  end
end

before do
  @storage = DatabasePersistence.new(logger)
end

after do
  @storage.disconnect
end

# View homepage
get "/" do
  redirect "/game_list"
end

# View game listing
get "/game_list" do
  @game_list = @storage.all_games

  erb :game_list, layout: :layout
end

# View game detail
get "/games/:id" do
  @game_id = params[:id].to_i
  @game = load_game(@game_id)
  @day_of_week = @game.start_time.wday

  erb :game, layout: :layout
end

# Delete game
post "/games/:id/delete" do
  @game_id = params[:id].to_i
  check_game_permission(@game_id)

  load_game(@game_id)
  @storage.delete_game(@game_id)

  session[:success] = "Game has been deleted."
  redirect "/game_list"
end

# Signup player to game
post "/games/:game_id/players/add" do
  @game_id = params[:game_id].to_i
  @game = load_game(@game_id)

  if @game.filled_slots >= @game.total_slots
    session[:error] = "Sorry, no empty slots remaining."

    status 422
    # Others must have filled up the slots. Force a refresh for the updated list.
    redirect "/games/#{@game_id}"
  end

  if session[:logged_in] && game_have_permission?(@game_id)
    signup_anon_player(@game_id, params[:player_name].strip)
  elsif session[:logged_in]
    if @storage.already_signed_up?(@game_id, session[:player_id])
      session[:error] = "You're already signed up!"

      status 422
      erb :game, layout: :layout
    else
      signup_player(@game_id, session[:player_id])
    end
  else
    signup_anon_player(@game_id, params[:player_name].strip)
  end
end

# Remove self from game
post "/games/:game_id/players/remove" do
  @game_id = params[:game_id].to_i

  if @storage.already_signed_up?(@game_id, session[:player_id])
    @storage.un_rsvp_player(params[:game_id], session[:player_id])

    session[:success] = "You have been removed from this game."
  else
    session[:error] = "You aren't signed up for this game!"

    status 422
    # Force a redirect to re-render the game view
  end

  redirect "/games/#{@game_id}"
end

# Remove player from game
post "/games/:game_id/players/:player_id/remove" do
  @game_id = params[:game_id].to_i
  @player_id = params[:player_id].to_i

  check_game_permission(@game_id)

  if @storage.already_signed_up?(@game_id, @player_id)
    @storage.un_rsvp_player(@game_id, @player_id)

    session[:success] = "Player removed from this game."
    redirect "/games/#{@game_id}"
  else
    session[:error] = "Player isn't signed up for this game!"

    # Force a redirect to re-render game page
    redirect "/games/#{@game_id}"
  end
end

# Confirm player payment
post "/games/:game_id/players/:player_id/confirm_paid" do
  @game_id = params[:game_id]
  @player_id = params[:player_id]

  @storage.confirm_paid(@game_id, @player_id)

  redirect "/games/#{@game_id}"
end

# Confirm all players' payment
post "/games/:game_id/players/confirm_all" do
  @game_id = params[:game_id]
  check_game_permission(@game_id)

  @storage.confirm_all_paid(@game_id)

  redirect "/games/#{@game_id}"
end

# Un-confirm player payment
post "/games/:game_id/players/:player_id/unconfirm_paid" do
  @game_id = params[:game_id]
  @player_id = params[:player_id]

  check_game_permission(@game_id)

  @storage.unconfirm_paid(@game_id, @player_id)

  redirect "/games/#{@game_id}"
end

# Confirm all players' payment
post "/games/:game_id/players/unconfirm_all" do
  @game_id = params[:game_id]

  check_game_permission(@game_id)

  @storage.unconfirm_all_paid(@game_id)

  redirect "/games/#{@game_id}"
end

# View group listing
get "/group_list" do
  @group_list = @storage.all_groups

  erb :group_list, layout: :layout
end

# View group detail
get "/groups/:group_id" do
  @group_id = params[:group_id].to_i
  @group = load_group(@group_id)
  @group_games = @storage.find_group_games(@group_id)

  @group_players = @storage.find_group_players(@group_id)

  erb :group, layout: :layout
end

# View group schedule
get "/groups/:group_id/schedule" do
  @group_id = params[:group_id].to_i
  check_group_permission(@group_id)

  @group = load_group(@group_id)

  erb :group_schedule, layout: :layout
end

def valid_notes?(notes)
  notes.nil? || notes.length <= 1000
end

# Edit group game schedule notes
post "/groups/:group_id/schedule/edit" do
  @group_id = params[:group_id].to_i
  check_group_permission(@group_id)

  @group = load_group(@group_id)

  if !valid_notes?(params[:notes])
    session[:error] = "Note must be less than or equal to 1000 characters."
    status 422
    erb :group_schedule, layout: :layout
  else
    @storage.edit_group_schedule_game_notes(@group_id, params[:notes])

    session[:success] = "Group notes updated."

    redirect "/groups/#{@group_id}/schedule"
  end
end

# View group schedule for a day of the week
get "/groups/:group_id/schedule/:day_of_week" do
  @group_id = params[:group_id].to_i
  check_group_permission(@group_id)

  @group = load_group(@group_id)
  @day_of_week = params[:day_of_week].to_i

  @games = @storage.find_group_template_games_for_day(@group_id, @day_of_week)

  erb :group_schedule_day_of_week, layout: :layout
end

# View add game to group schedule for a day of the week page
get "/groups/:group_id/schedule/:day_of_week/add" do
  @group_id = params[:group_id].to_i
  check_group_permission(@group_id)

  @group = load_group(@group_id)
  @day_of_week = params[:day_of_week].to_i
  @group_players = @storage.find_group_players(@group_id)

  erb :group_schedule_day_of_week_add_game
end

post "/groups/:group_id/schedule/publish" do
  @group_id = params[:group_id].to_i
  check_group_permission(@group_id)

  @group = load_group(@group_id)
  @publish_day = params[:publish_day].to_i

  scheduled_games = @storage.find_scheduled_games(@group_id)

  games_to_add = scheduled_games.map do |scheduled_game|
    days_til_game_day_from_publish_day = scheduled_game.start_time.wday - @publish_day

    if days_til_game_day_from_publish_day.negative?
      days_til_game_day_from_publish_day += DAYS_OF_WEEK.size
    end

    days_til_publish_day = @publish_day - Time.now.wday

    if days_til_publish_day.negative?
      days_til_publish_day += DAYS_OF_WEEK.size
    end

    game_day = Time.new +
               (days_til_publish_day + days_til_game_day_from_publish_day) * DAY_TO_SEC

    start_time = "#{game_day.year}-#{game_day.mon}-#{game_day.day} #{scheduled_game.start_time.hour}"

    Game.new(start_time: start_time,
             duration: scheduled_game.duration,
             group_name: scheduled_game.group_name,
             group_id: scheduled_game.group_id,
             location: scheduled_game.location,
             fee: scheduled_game.fee,
             total_slots: scheduled_game.total_slots,
             notes: @group.schedule_game_notes,
             template: false)
  end

  games_to_add.each do |game|
    @storage.add_game(game)
  end

  redirect "/game_list"
end

# View edit game page
get "/games/:id/edit" do
  @game_id = params[:id].to_i
  @game = load_game(@game_id)
  @group_id = @game.group_id
  @group = load_group(@group_id)
  @day_of_week = @game.start_time.wday

  erb :edit_game
end

post "/games/:id/edit" do
  @game_id = params[:id].to_i
  @game = @storage.find_game(@game_id)
  @group_id = @game.group_id
  check_group_permission(@group_id)

  @group = load_group(@group_id)
  @start_time = "#{params[:hour]}#{params[:am_pm]}"
  @day_of_week = @game.start_time.wday
  @group_players = @storage.find_group_players(@group_id)
  @duration = params[:duration].to_i
  @location = params[:location]
  @fee = params[:fee].to_i
  @total_slots = params[:total_slots].to_i

  if !valid_location?
    handle_invalid_location
    erb :edit_game
  elsif !valid_slots?
    handle_invalid_slots
    erb :edit_game
  elsif !valid_fee?
    handle_invalid_fee
    erb :edit_game
  else
    @start_time = "#{params[:hour]}#{params[:am_pm]}"
    @location = params[:location]
    @total_slots = params[:total_slots].to_i
    @fee = params[:fee].to_i

    game = Game.new(id: @game_id,
                    group_id: @group_id,
                    group_name:@group.name,
                    start_time: @start_time,
                    duration: @duration,
                    location: @location,
                    fee: @fee,
                    total_slots: @total_slots)

    @storage.edit_game(game)
    redirect "/games/#{@game_id}"
  end
end

def valid_location?
  (1..300).cover?(params[:location].length)
end

def handle_invalid_location
  session[:error] = "Location cannot be empty and total length cannot exceed 1000 characters."
  status 422
end

def valid_slots?
  params[:total_slots].to_i.between?(1, 1000)
end

def handle_invalid_slots
  session[:error] = "Slots must be between 1 and 1000."
  status 422
end

def valid_fee?
  params[:fee].to_i.between?(0, 1000)
end

def handle_invalid_fee
  session[:error] = "Fee must be between 0 and 1000."
  status 422
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

# Add game to group schedule for a day of the week page
post "/groups/:group_id/schedule/:day_of_week/add" do
  @group_id = params[:group_id].to_i
  check_group_permission(@group_id)

  @group = load_group(@group_id)
  @day_of_week = params[:day_of_week].to_i
  @group_players = @storage.find_group_players(@group_id)

  if !valid_location?
    handle_invalid_location
    erb :group_schedule_day_of_week_add_game
  elsif !valid_slots?
    handle_invalid_slots
    erb :group_schedule_day_of_week_add_game
  elsif !valid_fee?
    handle_invalid_fee
    erb :group_schedule_day_of_week_add_game
  else
    add_group_schedule_day_of_week_game

    redirect "/groups/#{@group_id}/schedule/#{@day_of_week}"
  end
end

# View player detail
get "/players/:id" do
  @player_id = params[:id].to_i
  @player = load_player(@player_id)

  erb :player, layout: :layout
end

# View login page
get "/login" do
  erb :login, layout: :layout
end

# Login
post "/login" do
  if valid_password?(params[:password]) &&
     correct_password?(params[:username], params[:password])
    session[:username] = params[:username]
    session[:player_id] = @storage.find_player_id(params[:username])
    session[:success] = "Welcome!"
    session[:logged_in] = true
    redirect "/game_list"
  else
    session[:error] = "Invalid Credentials!"
    status 422
    erb :login
  end
end

# Logout
post "/logout" do
  session[:logged_in] = false
  session[:username] = nil
  session[:player_id] = nil

  session[:success] = "You have been signed out."

  redirect "/game_list"
end

# View register page
get "/register" do
  if session[:logged_in]
    session[:error] = "You're already logged in."

    redirect "/game_list"
  else
    erb :register, layout: :layout
  end
end

# Register
post "/register" do
  if session[:logged_in]
    session[:error] = "You're already logged in."

    redirect "/game_list"
  elsif acc_exists?(params[:username])
    session[:error] = "That account name already exists."
    status 422

    erb :register, layout: :layout
  elsif !valid_username?(params[:username])
    session[:error] = "Username must consist of only letters and numbers, "\
                        "and must be between 4-10 characters."
    status 422

    erb :register, layout: :layout
  elsif !valid_password?(params[:password])
    session[:error] = "Password must be between 4-10 characters and cannot "\
                        "contain spaces."
    status 422

    erb :register, layout: :layout
  else
    register_acc(params[:username], params[:password])

    session[:success] = "Your account has been registered."
    session[:logged_in] = true
    session[:username] = params[:username]
    session[:player_id] = @storage.find_player_id(params[:username])

    redirect "/game_list"
  end
end
