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

end

# View group listing
get "/groups" do

end

# View group detail
get "/groups/:id" do

end


