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
