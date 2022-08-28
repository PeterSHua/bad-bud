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

    player.create(@storage)

    session[:success] = "Your account has been registered."
    session[:logged_in] = true
    session[:username] = params[:username]
    session[:player_id] = @storage.find_player_id(params[:username])

    redirect "/game_list"
  end
end

# View player detail
get "/players/:player_id" do
  @player_id = params[:player_id].to_i
  @player = Player.new(id: @player_id)
  @player.read(@storage)

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
  @player = Player.new(id: @player_id)
  @player.read(@storage)

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
  @player = Player.new(id: @player_id)
  @player.read(@storage)

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

    player.update(@storage)
    session[:success] = "Player updated."

    redirect "/players/#{@player_id}"
  end
end
