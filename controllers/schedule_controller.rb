# View add game to group schedule for a day of the week page
get "/groups/:group_id/schedule/:day_of_week/add" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)
  @day_of_week = params[:day_of_week].to_i

  group_url_error = url_error_for_group_need_permission
  schedule_day_url_error = url_error_for_schedule_day

  if group_url_error
    session[:error] = group_url_error
    redirect "/group_list"
  elsif schedule_day_url_error
    session[:error] = schedule_day_url_error
    redirect "/groups/#{@group_id}/schedule"
  else
    @group_players = @storage.find_group_players(@group_id)

    erb :group_schedule_day_of_week_add_game, layout: :layout do
      erb :game_details
    end
  end
end

# Publish weekly schedule games
post "/groups/:group_id/schedule/publish" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)

  url_error = url_error_for_group_need_permission
  input_error = input_error_for_post_schedule

  if url_error
    session[:error] = url_error
    redirect "/group_list"
  elsif input_error
    session[:error] = input_error
    erb :group_schedule, layout: :layout
  else
    @day_of_week = params[:day_of_week].to_i

    scheduled_games = @group.read_scheduled_games(@storage)

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
end

# Add game to group schedule for a day of the week page
post "/groups/:group_id/schedule/:day_of_week/add" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)
  @day_of_week = params[:day_of_week].to_i
  @group_players = @storage.find_group_players(@group_id)

  group_url_error = url_error_for_group_need_permission
  schedule_day_url_error = url_error_for_schedule_day
  input_error = error_for_create_game

  if group_url_error
    session[:error] = group_url_error
    redirect "/group_list"
  elsif schedule_day_url_error
    session[:error] = schedule_day_url_error
    redirect "/groups/#{@group_id}/schedule"
  elsif input_error
    session[:error] = input_error
    status 422
    erb :group_schedule_day_of_week_add_game, layout: :layout do
      erb :game_details
    end
  else
    date = day_of_week_to_date(@day_of_week)

    game = Game.new(start_time: "#{date} #{params[:hour]}#{params[:am_pm]}",
                duration: params[:duration].to_i,
                group_name: @group.name,
                group_id: @group.id.to_i,
                location: params[:location],
                level: params[:level],
                fee: params[:fee].to_i,
                total_slots: params[:total_slots].to_i,
                template: true)

    @storage.add_game(game)

    session[:success] = "Added game to schedule."
    redirect "/groups/#{@group_id}/schedule/#{@day_of_week}"
  end
end

# View group schedule
get "/groups/:group_id/schedule" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)

  error = url_error_for_group_need_permission

  if error
    session[:error] = error
    redirect "/group_list_list"
  else
    erb :group_schedule, layout: :layout
  end
end

# Edit group game schedule notes
post "/groups/:group_id/schedule/edit" do
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)

  url_error = url_error_for_group_need_permission
  input_error = input_error_for_group_schedule

  if url_error
    session[:error] = url_error
    redirect "/group_list"
  elsif input_error
    session[:error] = input_error
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
  force_login

  @group_id = params[:group_id].to_i
  @group = @storage.find_group(@group_id)
  @day_of_week = params[:day_of_week].to_i

  group_url_error = url_error_for_group_need_permission
  schedule_day_url_error = url_error_for_schedule_day

  if group_url_error
    session[:error] = group_url_error
    redirect "/group_list"
  elsif schedule_day_url_error
    session[:error] = schedule_day_url_error
    redirect "/groups/#{@group_id}/schedule"
  else
    @games = @storage.find_group_template_games_for_day(@group_id, @day_of_week)

    erb :group_schedule_day_of_week, layout: :layout
  end
end
