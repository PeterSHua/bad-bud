require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "bcrypt"

require_relative "lib/database_persistence"
require_relative "lib/game.rb"
require_relative "lib/group.rb"
require_relative "lib/player.rb"
require_relative "lib/location.rb"

configure do
  enable :sessions
  set :session_secret, "secret" # fix
  set :erb, escape_html: true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "lib/*.rb"
end

helpers do

end

def logged_in?
  session[:logged_in]
end

def prompt_login
  return if logged_in?

  session[:message] = "You must be signed in to do that."
  redirect "/"
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

def load_location(id)
  location = @storage.find_location(id)
  return location if location

  session[:error] = "The specified location was not found."
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
    erb :game, layout: :layout
  else
    @storage.rsvp_anon_player(game_id, player_name)

    session[:success] = "You've been signed up."
    redirect "/games/#{@game_id}"
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

# Add player to game
post "/games/:game_id/players" do
  @game_id = params[:game_id].to_i
  @game = load_game(@game_id)

  if @game.filled_slots >= @game.total_slots
    session[:error] = "Sorry, no empty slots remaining."

    redirect "/games/#{@game_id}"
  end

  if session[:logged_in]
    signup_player(@game_id, session[:player_id])
  else
    signup_anon_player(@game_id, params[:player_name].strip)
  end
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

  erb :group, layout: :layout
end

# View location detail
get "/locations/:id" do
  @location_id = params[:id].to_i
  @location = load_location(@location_id)

  erb :location, layout: :layout
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
