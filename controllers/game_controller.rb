# View game listing
get "/game_list" do
  @game_list = @storage.all_games

  erb :game_list, layout: :layout
end

# View create game page
get "/games/create" do
  force_login

  @player_id = session[:player_id]
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
  @notes = params[:notes]
  @player_id = session[:player_id]
  @groups = @storage.find_groups_is_organizer(@player_id)
  @group_id = params[:group_id].to_i

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
    game = Game.new(group_id: @group_id,
                start_time: @start_time,
                duration: @duration,
                location: @location,
                level: @level,
                fee: @fee,
                total_slots: @total_slots,
                notes: @notes)

    game.create(@storage)

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

  @game = Game.new(id: @game_id)
  @game.read(@storage)

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

# View edit game page
get "/games/:game_id/edit" do
  force_login

  @game_id = params[:game_id].to_i
  @game = Game.new(id: @game_id)
  @game.read(@storage)

  @group_id = @game&.group_id
  @group = Group.new(id: @group_id)
  @group.read(@storage)

  error = error_for_view_edit_game

  if error
    redirect "/game_list"
  else
    @group_id = @game.group_id
    @group = Group.new(id: @group_id)
    @group.read(@storage)
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
  @notes = params[:notes]

  @game = Game.new(id: @game_id)
  @game.read(@storage)

  @group_id = @game&.group_id
  @group = Group.new(id: @group_id)
  @group.read(@storage)

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
                    total_slots: @total_slots,
                    notes: @notes)

    game.update(@storage)

    session[:success] = "Game was updated."
    redirect "/games/#{@game_id}"
  end
end

# Delete game
post "/games/:game_id/delete" do
  force_login

  @game_id = params[:game_id].to_i
  @game = Game.new(id: @game_id)
  @game.read(@storage)

  error = error_for_delete_game

  if error
    session[:error] = error
  else
    @game.delete(@storage)
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
  @game = Game.new(id: @game_id)
  @game.read(@storage)
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
  @game = Game.new(id: @game_id)
  @game.read(@storage)

  @player_id = params[:player_id].to_i
  @player = Player.new(id: @player_id)
  @player.read(@storage)

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
  @game = Game.new(id: @game_id)
  @game.read(@storage)

  @player_id = params[:player_id].to_i
  @player = Player.new(id: @player_id)
  @player.read(@storage)

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
  @game = Game.new(id: @game_id)
  @game.read(@storage)

  @player_id = params[:player_id].to_i
  @player = Player.new(id: @player_id)
  @player.read(@storage)

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
  @game = Game.new(id: @game_id)
  @game.read(@storage)

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
  @game = Game.new(id: @game_id)
  @game.read(@storage)

  @player_id = params[:player_id].to_i
  @player = Player.new(id: @player_id)
  @player.read(@storage)

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
  @game = Game.new(id: @game_id)
  @game.read(@storage)

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
