require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"

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
  require "sinatra/reloader"
  also_reload "lib/*.rb"
end

helpers do

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

# Add player without account to game
post "/games/:game_id/players" do
  @game_id = params[:game_id].to_i
  @game = load_game(@game_id)
  player_name = params[:player_name].strip

  error = error_for_player_name(player_name)
  if error
    session[:error] = error
    erb :game, layout: :layout
  else
    @storage.rsvp_anon_player(@game_id, player_name)

    session[:success] = "You've been added."
    redirect "/games/#{@game_id}"
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
