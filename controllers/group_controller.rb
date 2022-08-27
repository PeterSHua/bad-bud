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

    erb :group_create, layout: :layout
  else
    @group_id = @storage.last_group_id + 1

    group = Group.new(id: @group_id,
                      name: @group_name,
                      about: @group_about)

    group.create(@storage)

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
    redirect "/group_list"
  else
    @group_games = @group.read_games(@storage)
    @group_players = @storage.find_group_players(@group_id)

    erb :group, layout: :layout
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
  input_error = input_error_for_edit_group

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

    group.update(@storage)

    session[:success] = "Group updated."
    redirect "/groups/#{@group_id}"
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
    @group.delete(@storage)
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

# Remove player from group
post "/groups/:group_id/players/:player_id/remove" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)

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
  @group = @storage.find_group(@group_id)

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
  @group = @storage.find_group(@group_id)

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
  elsif @storage.organizer_count(@group_id) <= 1
    session[:error] = "Can't demote the sole organizer."
    redirect "/groups/#{@group_id}"
  else
    @storage.remove_organizer(@group_id, @player_id)
    session[:success] = "Player demoted."
    redirect "/groups/#{@group_id}"
  end
end
