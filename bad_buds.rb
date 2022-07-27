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
  location = @storage.find_location(idd)
  return location if location

  session[:error] = "The specified location was not found."
  redirect "/game_list"
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

# View group listing
get "/group_list" do
  @group_list = @storage.all_groups

  erb :group_list, layout: :layout
end

# View group detail
get "/groups/:group_id" do
  @group_id = params[:group_id].to_i
  @group_games = @storage.find_group_games(@group_id)

  erb :group, layout: :layout
end

# View location detail
get "/locations/:id" do
  @location_id = params[:id].to_i
  @location = load_location(@location_id)

  erb :location, layout: :layout
end
