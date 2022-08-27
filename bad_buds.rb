require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "bcrypt"
require "require_all"

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


# View login page
get "/login" do
  erb :login, layout: :layout
end

# Login
post "/login" do
  error = error_for_login

  if error
    session[:error] = error
    status 422
    erb :login
  else
    session[:username] = params[:username]
    session[:player_id] = @storage.find_player_id(params[:username])
    session[:success] = "Welcome!"
    session[:logged_in] = true
    redirect "/game_list"
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
  url_error = url_error_for_register
  input_error = input_error_for_register

  if url_error
    session[:error] = url_error
    redirect "/game_list"
  elsif input_error
    session[:error] = input_error
    status 422

    erb :register, layout: :layout
  else
    encrypted_password = BCrypt::Password.create(params[:password]).to_s

    player = Player.new(username: params[:username],
                        password: encrypted_password,
                        name: params[:username])

    @storage.add_player(player)

    session[:success] = "Your account has been registered."
    session[:logged_in] = true
    session[:username] = params[:username]
    session[:player_id] = @storage.find_player_id(params[:username])

    redirect "/game_list"
  end
end

not_found do
  'This is nowhere to be found.'
end
