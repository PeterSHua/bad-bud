require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "bcrypt"

require_relative "lib/database_persistence"
require_relative "lib/game"
require_relative "lib/group"
require_relative "lib/player"

require_relative "lib/view_helpers"
require_relative "lib/route_helpers"

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

# View create game page
get "/games/create" do
  force_login

  @groups = @storage.find_groups_is_organizer(@player_id)

  erb :game_create, layout: :layout do
    erb :game_details
  end
end

# Create game
post "/games/create" do
  force_login

  @start_time = "#{params[:hour]}#{params[:am_pm]}"
  @duration = params[:duration].to_i
  @location = params[:location]
  @level = params[:level]
  @total_slots = params[:total_slots].to_i
  @fee = params[:fee].to_i
  @player_id = session[:player_id]
  @groups = @storage.find_groups_is_organizer(@player_id)
  @group_id = params[:group_id].to_i

  @groups = @storage.find_groups_is_organizer(@player_id)

  if no_group_selected?
    create_group_entry_for_game_without_group
  end

  error = error_for_create_game

  if error
    session[:error] = error
    status 422

    erb :game_create, layout: :layout do
      erb :game_details
    end
  else
    create_game

    session[:success] = "Game was created."
    redirect "/game_list"
  end
end

# View game detail
get "/games/:game_id" do
  @start_time = "#{params[:hour]}#{params[:am_pm]}"
  @duration = params[:duration].to_i
  @location = params[:location]
  @level = params[:level]
  @total_slots = params[:total_slots].to_i
  @fee = params[:fee].to_i
  @player_id = session[:player_id].to_i
  @game_id = params[:game_id].to_i

  @game = @storage.find_game(@game_id)
  error = error_for_view_game

  if error
    session[:error] = error
    redirect "/game_list"
  else
    @day_of_week = @game.start_time.wday
    @group_id = @game.group_id
    @group_players = @storage.find_group_players(@group_id)

    erb :game, layout: :layout
  end
end

# Delete game
post "/games/:game_id/delete" do
  force_login

  @game_id = params[:game_id].to_i
  @game = @storage.find_game(@game_id)

  error = error_for_delete_game

  if error
    session[:error] = error
  else
    @storage.delete_game(@game_id)
    session[:success] = "Game has been deleted."
  end

  redirect "/game_list"
end

def signup_anon_player(game_id, name)
  @storage.rsvp_anon_player(game_id, name)
  session[:success] = "Player has been signed up."
end

# Add unregistered player to game
post "/games/:game_id/players/add" do
  @game_id = params[:game_id].to_i
  @game = @storage.find_game(@game_id)
  @group_id = @game.group_id
  @group_players = @storage.find_group_players(@group_id)

  url_error = url_error_for_add_anon_player_to_game
  input_error = input_error_for_add_anon_player_to_game

  if url_error
    session[:error] = url_error
    redirect "/game_list"
  elsif input_error
    session[:error] = input_error
    status 422
    erb :game, layout: :layout
  else
    signup_anon_player(@game_id, params[:name].strip)

    session[:success] = "Player has been signed up."
    redirect "/games/#{@game_id}"
  end
end

# Add registered player to game
post "/games/:game_id/players/:player_id/add" do
  force_login

  @game_id = params[:game_id].to_i
  @game = @storage.find_game(@game_id)

  @player_id = params[:player_id].to_i
  @player = @storage.find_player(@player_id)

  @group_id = @game.group_id
  @group_players = @storage.find_group_players(@group_id)

  game_url_error = game_url_error_for_player_rsvp_in_game
  player_url_error = player_url_error_for_player_rsvp_in_game
  input_error = input_error_for_add_reg_player_to_game

  if game_url_error
    session[:error] = game_url_error
    redirect "/game_list"
  elsif player_url_error
    session[:error] = player_url_error
    redirect "/#{@game_id}"
  elsif input_error
    session[:error] = input_error
    status 422
    erb :game, layout: :layout
  else
    @storage.rsvp_player(@game_id, @player_id)

    session[:success] = "Player added to this game."
    redirect "/games/#{@game_id}"
  end
end

# Remove player from game
post "/games/:game_id/players/:player_id/remove" do
  force_login

  @game_id = params[:game_id].to_i
  @game = @storage.find_game(@game_id)

  @player_id = params[:player_id].to_i
  @player = @storage.find_player(@player_id)

  @group_id = @game&.group_id
  @group_players = @storage.find_group_players(@group_id)

  game_url_error = game_url_error_for_player_rsvp_in_game
  player_url_error = player_url_error_for_player_rsvp_in_game

  if game_url_error
    session[:error] = game_url_error
    redirect "/game_list"
  elsif player_url_error
    session[:error] = player_url_error
    redirect "/games/#{@game_id}"
  else
    @storage.un_rsvp_player(@game_id, @player_id)

    session[:success] = "Player removed from this game."
    redirect "/games/#{@game_id}"
  end
end

# Confirm player payment
post "/games/:game_id/players/:player_id/confirm_paid" do
  force_login

  @game_id = params[:game_id].to_i
  @game = @storage.find_game(@game_id)

  @player_id = params[:player_id].to_i
  @player = @storage.find_player(@player_id)

  @group_id = @game&.group_id
  @group_players = @storage.find_group_players(@group_id)

  game_url_error = game_url_error_for_player_confirm_payment_in_game
  player_url_error = player_url_error_for_player_confirm_payment_in_game

  if game_url_error
    session[:error] = game_url_error
    redirect "/game_list"
  elsif player_url_error
    session[:error] = player_url_error
    redirect "/games/#{@game_id}"
  else
    @storage.confirm_paid(@game_id, @player_id)

    session[:success] = "Confirmed player payment."
    redirect "/games/#{@game_id}"
  end
end

# Confirm all players' payment
post "/games/:game_id/players/confirm_all" do
  force_login

  @game_id = params[:game_id].to_i
  @game = @storage.find_game(@game_id)

  @group_id = @game&.group_id
  @group_players = @storage.find_group_players(@group_id)

  error = game_url_error_for_player_confirm_payment_in_game

  if error
    session[:error] = error
    redirect "/game_list"
  else
    @storage.confirm_all_paid(@game_id)

    session[:success] = "All player payment confirmed."
    redirect "/games/#{@game_id}"
  end
end

# Un-confirm player payment
post "/games/:game_id/players/:player_id/unconfirm_paid" do
  force_login

  @game_id = params[:game_id].to_i
  @game = @storage.find_game(@game_id)

  @player_id = params[:player_id].to_i
  @player = @storage.find_player(@player_id)

  @group_id = @game&.group_id
  @group_players = @storage.find_group_players(@group_id)

  game_url_error = game_url_error_for_player_confirm_payment_in_game
  player_url_error = player_url_error_for_player_confirm_payment_in_game

  if game_url_error
    session[:error] = game_url_error
    redirect "/game_list"
  elsif player_url_error
    session[:error] = player_url_error
    redirect "/games/#{@game_id}"
  else
    @storage.unconfirm_paid(@game_id, @player_id)
    redirect "/games/#{@game_id}"
  end
end

# Unconfirm all players' payment
post "/games/:game_id/players/unconfirm_all" do
  force_login

  @game_id = params[:game_id].to_i
  @game = @storage.find_game(@game_id)

  @group_id = @game&.group_id
  @group_players = @storage.find_group_players(@group_id)

  error = game_url_error_for_player_confirm_payment_in_game

  if error
    session[:error] = game_url_error
    redirect "/game_list"
  else
    @storage.unconfirm_all_paid(@game_id)

    session[:success] = "All player payment un-confirmed."
    redirect "/games/#{@game_id}"
  end
end

# View group listing
get "/group_list" do
  @group_list = @storage.all_groups

  erb :group_list, layout: :layout
end

# View create group page
get "/groups/create" do
  force_login

  erb :group_create, layout: :layout
end

# Create group
post "/groups/create" do
  force_login

  @group_name = params[:name]
  @group_about = params[:about]

  error = input_error_for_group

  if error
    session[:error] = error
    status 422

    erb :group_edit, layout: :layout
  else
    @group_id = @storage.last_group_id + 1

    group = Group.new(id: @group_id,
                      name: @group_name,
                      about: @group_about)

    @storage.add_group(group)
    @storage.add_player_to_group(@group_id, session[:player_id])
    @storage.make_organizer(@group_id, session[:player_id])

    session[:success] = "Group was created."
    redirect "/groups/#{@group_id}"
  end
end

# View group detail
get "/groups/:group_id" do
  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)

  error = error_for_group_no_permission

  if error
    session[:error] = error
    redirect "/group_list_list"
  else
    @group_games = @storage.find_group_games(@group_id)
    @group_players = @storage.find_group_players(@group_id)

    erb :group, layout: :layout
  end
end

# Delete group
post "/groups/:group_id/delete" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)

  error = url_error_for_group_need_permission

  if error
    session[:error] = error
    status 422
    redirect "/group_list"
  else
    @storage.delete_group(@group_id)
    session[:success] = "Group has been deleted."
  end

  redirect "/group_list"
end

# Join group
post "/groups/:group_id/join" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)

  error = error_for_group_no_permission

  if error
    redirect "/group_list"
  else
    @storage.add_player_to_group(@group_id, session[:player_id])
    session[:success] = "Joined group."

    redirect "/groups/#{@group_id}"
  end
end

# Leave group
post "/groups/:group_id/leave" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)

  error = error_for_group_no_permission

  if error
    redirect "/group_list"
  else
    @storage.remove_player_from_group(@group_id, session[:player_id])
    session[:success] = "Left group."

    redirect "/groups/#{@group_id}"
  end
end

# View edit group page
get "/groups/:group_id/edit" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)

  error = url_error_for_group_need_permission

  if error
    redirect "/group_list"
  else
    @group_players = @storage.find_group_players(@group_id)
    erb :group_edit, layout: :layout
  end
end

# Edit group
post "/groups/:group_id/edit" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)

  url_error = url_error_for_group_need_permission
  input_error = input_error_for_group

  if url_error
    session[:error] = url_error
    redirect "/group_list"
  elsif input_error
    session[:error] = input_error
    status 422

    erb :group_edit, layout: :layout
  else
    group = Group.new(id: @group_id,
                      name: params[:name],
                      about: params[:about])

    @storage.edit_group(group)

    session[:success] = "Group updated."
    redirect "/groups/#{@group_id}"
  end
end

# Remove player from group
post "/groups/:group_id/players/:player_id/remove" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_game(@group_id)

  @player_id = params[:player_id].to_i
  @player = @storage.find_player(@player_id)

  group_url_error = url_error_for_group_need_permission
  player_url_error = player_url_error_no_permission

  if group_url_error
    session[:error] = group_url_error
    redirect "/group_list"
  elsif player_url_error
    session[:error] = player_url_error
    redirect "/groups/#{@group_id}"
  else
    @storage.remove_player_from_group(@group_id, @player_id)
    session[:success] = "Player removed."
    redirect "/groups/#{@group_id}"
  end
end

# Promote player
post "/groups/:group_id/players/:player_id/promote" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_game(@group_id)

  @player_id = params[:player_id].to_i
  @player = @storage.find_player(@player_id)

  group_url_error = url_error_for_group_need_permission
  player_url_error = player_url_error_no_permission

  if group_url_error
    session[:error] = group_url_error
    redirect "/group_list"
  elsif player_url_error
    session[:error] = player_url_error
    redirect "/groups/#{@group_id}"
  else
    @storage.make_organizer(@group_id, @player_id)
    session[:success] = "Player promoted."
    redirect "/groups/#{@group_id}"
  end
end

# Demote player
post "/groups/:group_id/players/:player_id/demote" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_game(@group_id)

  @player_id = params[:player_id].to_i
  @player = @storage.find_player(@player_id)

  group_url_error = url_error_for_group_need_permission
  player_url_error = player_url_error_no_permission

  if group_url_error
    session[:error] = group_url_error
    redirect "/group_list"
  elsif player_url_error
    session[:error] = player_url_error
    redirect "/groups/#{@group_id}"
  else
    @storage.remove_organizer(@group_id, @player_id)
    session[:success] = "Player demoted."
    redirect "/groups/#{@group_id}"
  end
end

# View group schedule
get "/groups/:group_id/schedule" do
  @group_id = params[:group_id].to_i
  check_group_permission(@group_id)

  @group = @storage.find_group(@group_id)

  erb :group_schedule, layout: :layout
end

# Edit group game schedule notes
post "/groups/:group_id/schedule/edit" do
  @group_id = params[:group_id].to_i
  check_group_permission(@group_id)

  @group = @storage.find_group(@group_id)

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

  @group = @storage.find_group(@group_id)
  @day_of_week = params[:day_of_week].to_i

  @games = @storage.find_group_template_games_for_day(@group_id, @day_of_week)

  erb :group_schedule_day_of_week, layout: :layout
end

# View add game to group schedule for a day of the week page
get "/groups/:group_id/schedule/:day_of_week/add" do
  @group_id = params[:group_id].to_i
  check_group_permission(@group_id)

  @group = @storage.find_group(@group_id)
  @day_of_week = params[:day_of_week].to_i
  @group_players = @storage.find_group_players(@group_id)

  erb :group_schedule_day_of_week_add_game, layout: :layout do
    erb :game_details
  end
end

# Publish weekly schedule games
post "/groups/:group_id/schedule/publish" do
  @group_id = params[:group_id].to_i
  check_group_permission(@group_id)

  @group = @storage.find_group(@group_id)
  @publish_day = params[:publish_day].to_i

  scheduled_games = @storage.find_scheduled_games(@group_id)

  games_to_add = scheduled_games.map do |scheduled_game|
    start_time = calc_start_time(scheduled_game)

    Game.new(start_time: start_time, duration: scheduled_game.duration,
             group_name: scheduled_game.group_name,
             group_id: scheduled_game.group_id,
             location: scheduled_game.location,
             level: scheduled_game.level,
             fee: scheduled_game.fee,
             filled_slots: scheduled_game.filled_slots,
             total_slots: scheduled_game.total_slots,
             players: scheduled_game.players,
             notes: @group.schedule_game_notes, template: false)
  end

  games_to_add.each do |game|
    @storage.add_game(game)
    game_id = @storage.last_game_id

    game.players.each do |player|
      @storage.rsvp_player(game_id, player.id)
    end
  end

  redirect "/game_list"
end

# View edit game page
get "/games/:game_id/edit" do
  force_login

  @game_id = params[:game_id].to_i
  @game = @storage.find_game(@game_id)

  error = error_for_view_edit_game

  if error
    redirect "/game_list"
  else
    @group_id = @game.group_id
    @group = @storage.find_group(@group_id)
    @day_of_week = @game.start_time.wday

    erb :game_edit, layout: :layout do
      erb :game_details
    end
  end
end

# Edit game
post "/games/:game_id/edit" do
  force_login

  @game_id = params[:game_id].to_i
  @start_time = "#{params[:hour]}#{params[:am_pm]}"
  @start_time = "#{params[:date]} #{@start_time}" if !params[:date].nil?
  @duration = params[:duration].to_i
  @location = params[:location]
  @level = params[:level]
  @fee = params[:fee].to_i
  @total_slots = params[:total_slots].to_i

  @game = @storage.find_game(@game_id)
  @group_id = @game&.group_id
  @group = @storage.find_group(@group_id)

  url_error = url_error_for_edit_game
  input_error = input_error_for_edit_game

  if url_error
    session[:error] = url_error
    redirect "/game_list"
  elsif input_error
    session[:error] = input_error
    status 422

    erb :game_edit, layout: :layout do
      erb :game_details
    end
  else
    @day_of_week = @game.start_time.wday
    @group_players = @storage.find_group_players(@group_id)

    game = Game.new(id: @game_id,
                    group_id: @group_id,
                    group_name: @group.name,
                    start_time: @start_time,
                    duration: @duration,
                    location: @location,
                    level: @level,
                    fee: @fee,
                    total_slots: @total_slots)

    @storage.edit_game(game)

    session[:success] = "Game was updated."
    redirect "/games/#{@game_id}"
  end
end

# Add game to group schedule for a day of the week page
post "/groups/:group_id/schedule/:day_of_week/add" do
  @group_id = params[:group_id].to_i
  check_group_permission(@group_id)

  @group = @storage.find_group(@group_id)
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

    redirect "/groups/#{@group_id}/schedule/#{@day_of_week}"
  end
end

# View player detail
get "/players/:player_id" do
  @player_id = params[:player_id].to_i
  @player = @storage.find_player(@player_id)

  error = player_url_error_no_permission

  if error
    redirect "/game_list"
  else
    erb :player, layout: :layout
  end
end

# View edit player detail
get "/players/:player_id/edit" do
  force_login

  @player_id = params[:player_id].to_i
  @player = @storage.find_player(@player_id)

  error = player_url_error_need_permission

  if error
    redirect "/game_list"
  else
    erb :player_edit, layout: :layout
  end
end

# Edit player detail
post "/players/:player_id/edit" do
  force_login

  @player_id = params[:player_id].to_i
  @player = @storage.find_player(@player_id)

  @name = params[:name]
  @rating = params[:rating].to_i
  @about = params[:about]
  @password = params[:password]

  url_error = player_url_error_need_permission
  input_error = input_error_for_edit_player

  if url_error
    session[:error] = url_error
    redirect "/game_list"
  elsif input_error
    session[:error] = input_error
    status 422

    erb :player_edit, layout: :layout
  else
    new_password = if @password.empty?
                     @player.password
                   else
                     BCrypt::Password.create(@password)
                   end

    player = Player.new(id: @player_id,
                        name: @name,
                        rating: @rating,
                        about: @about,
                        username: @player.username,
                        password: new_password)

    @storage.edit_player(player)
    session[:success] = "Player updated."

    redirect "/players/#{@player_id}"
  end
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
