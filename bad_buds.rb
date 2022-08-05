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
  def already_signed_up?(game_id, player_id)
    @storage.already_signed_up?(game_id, player_id)
  end

  def game_organizer?(game_id, player_id)
    @storage.game_organizer?(game_id, player_id)
  end

  def group_organizer?(group_id, player_id)
    @storage.group_organizer?(group_id, player_id)
  end
end

def game_have_permission?(game_id)
  if session[:logged_in] && @storage.game_organizer?(game_id, session[:player_id])
    return
  end

  session[:error] = "You don't have permission to do that!"

  redirect "/game_list"
end

def group_have_permission?(group_id)
  if session[:logged_in] && @storage.group_organizer?(group_id, session[:player_id])
    return
  end

  session[:error] = "You don't have permission to do that!"

  redirect "/group_list"
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

  session[:success] = "You've been signed up."
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

    session[:success] = "You've been signed up."
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

  erb :game, layout: :layout
end

# Delete game
post "/games/:id/delete" do
  @game_id = params[:id].to_i
  game_have_permission?(@game_id)

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

  if session[:logged_in]
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

  game_have_permission?(@game_id)

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
  game_have_permission?(@game_id)

  @storage.confirm_all_paid(@game_id)

  redirect "/games/#{@game_id}"
end

# Un-confirm player payment
post "/games/:game_id/players/:player_id/unconfirm_paid" do
  @game_id = params[:game_id]
  @player_id = params[:player_id]

  game_have_permission?(@game_id)

  @storage.unconfirm_paid(@game_id, @player_id)

  redirect "/games/#{@game_id}"
end

# Confirm all players' payment
post "/games/:game_id/players/unconfirm_all" do
  @game_id = params[:game_id]

  game_have_permission?(@game_id)

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
  @group = load_group(@group_id)

  group_have_permission?(@group_id)

  erb :group_schedule, layout: :layout
end

def valid_notes?(notes)
  notes.nil? || notes.length <= 1000
end

# Edit group game schedule notes
post "/groups/:group_id/schedule/edit" do
  @group_id = params[:group_id].to_i
  @group = load_group(@group_id)

  group_have_permission?(@group_id)

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

# View group sunday schedule
get "/groups/:group_id/schedule/sunday" do
  @group_id = params[:group_id].to_i
  @group = load_group(@group_id)

  erb :group_schedule_sunday, layout: :layout
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
