require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "bcrypt"
require "require_all"

require "pry-byebug"

require_all "lib"
require_all "controllers"

ROOT = File.expand_path(__dir__)

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
  set :erb, escape_html: true
end

configure(:development) do
  require "sinatra/reloader" if development?
  also_reload "controllers/*.rb"
  also_reload "lib/*.rb"
end

before do
  @storage = DatabasePersistence.new(logger)
  https_required
end

after do
  @storage.disconnect
end

# View homepage
get "/" do
  redirect "/game_list"
end

not_found do
  'This is nowhere to be found.'
end
