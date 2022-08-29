helpers do
  def already_signed_up?(game_id, player_id)
    @storage.already_signed_up?(game_id, player_id)
  end

  def game_organizer?(game_id, player_id)
    @storage.game_organizer?(game_id, player_id)
  end

  def group_organizer?(group_id, player_id)
    @storage.group_organizer?(group_id, player_id)
  end

  def profile_owner?(profile_id)
    profile_id == session[:player_id].to_i
  end

  def day_of_week_to_name(day_of_week)
    TimeDate::DAYS_OF_WEEK[day_of_week]
  end

  def display_time(game)
    game_duration_secs = game.duration * TimeDate::MINS_IN_HOUR *
                         TimeDate::SECS_IN_MIN

    "#{game.start_time.strftime('%l:%M%p')} - "\
    "#{(game.start_time + game_duration_secs).strftime('%l:%M%p')}"
  end

  def todays_date
    Time.now.to_s.split(' ').first
  end

  def select_duration(duration)
    if (params[:duration] && params[:duration].to_i == duration) ||
       (@game && (@game.duration == duration))
      "selected"
    else
      ""
    end
  end

  def select_rating(rating)
    if (params[:rating] && params[:rating].to_i == rating) ||
       (@player && (@player.rating == rating))
      "selected"
    else
      ""
    end
  end

  def normalize_to_12hr(hour)
    return nil if hour.nil?
    hour > TimeDate::HOUR_HAND_MAX ? hour - TimeDate::HOUR_HAND_MAX : hour
  end

  def select_date(time)
    time.to_s.split(' ').first
  end

  def select_hour(hour)
    if (params[:hour] && params[:hour] == hour) ||
       (@game && (normalize_to_12hr(@game.start_time&.hour) == hour))
      "selected"
    else
      ""
    end
  end

  def select_am
    if (params[:am_pm] && params[:am_pm] == 'am') ||
       (@game && ((@game.start_time.hour == TimeDate::MAX_DURATION_HOURS) ||
       (@game.start_time.hour < TimeDate::HOUR_HAND_MAX)))
      "selected"
    else
      ""
    end
  end

  def select_pm
    if (params[:am_pm] && params[:am_pm] == 'pm') ||
       (@game && (@game.start_time.hour != TimeDate::MAX_DURATION_HOURS &&
        @game.start_time.hour >= TimeDate::HOUR_HAND_MAX))
      "selected"
    else
      ""
    end
  end

  def profile_pic_exists?
    File.file?("#{ROOT}/public/images/#{@player.username}.jpg")
  end

  def game_notes_text
    return params[:notes] unless params[:notes].nil?

    if !@game.nil? && !@game&.notes&.empty?
      @game&.notes
    else
      @group&.schedule_game_notes
    end
  end
end
