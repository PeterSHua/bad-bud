helpers do
  # Fix - remove
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
    DAYS_OF_WEEK[day_of_week]
  end

  def display_time(game)
    "#{game.start_time.strftime('%l:%M%p')} - "\
    "#{(game.start_time + game.duration * 60 * 60).strftime('%l:%M%p')}"
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
    hour > HOUR_HAND_MAX ? hour - HOUR_HAND_MAX : hour
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
       (@game && ((@game.start_time.hour == MAX_DURATION_HOURS) ||
       (@game.start_time.hour < HOUR_HAND_MAX)))
      "selected"
    else
      ""
    end
  end

  def select_pm
    if (params[:am_pm] && params[:am_pm] == 'pm') ||
       (@game && (@game.start_time.hour != MAX_DURATION_HOURS &&
        @game.start_time.hour >= HOUR_HAND_MAX))
      "selected"
    else
      ""
    end
  end

  def profile_pic_exists?
    File.file?("#{ROOT}/public/images/#{@player.username}.jpg")
  end
end
