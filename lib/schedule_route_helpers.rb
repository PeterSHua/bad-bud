def valid_schedule_day?
  params[:day_of_week].to_i.to_s == params[:day_of_week] &&
    (0...TimeDate::DAYS_OF_WEEK.size).cover?(params[:day_of_week].to_i)
end

def handle_invalid_schedule_day
  session[:error] = "Invalid day of the week."
end

def day_of_week_to_date(day)
  case day
  when 0 then TimeDate::SUN_DATE
  when 1 then TimeDate::MON_DATE
  when 2 then TimeDate::TUES_DATE
  when 3 then TimeDate::WED_DATE
  when 4 then TimeDate::THURS_DATE
  when 5 then TimeDate::FRI_DATE
  when 6 then TimeDate::SAT_DATE
  end
end

def normalize_day(day)
  day + TimeDate::DAYS_OF_WEEK.size
end

def calc_start_time(scheduled_game)
  days_btwn_publish_game = scheduled_game.start_time.wday - @day_of_week

  if days_btwn_publish_game <= 0
    days_btwn_publish_game = normalize_day(days_btwn_publish_game)
  end

  days_til_publish = @day_of_week - Time.now.wday

  if days_til_publish <= 0
    days_til_publish = normalize_day(days_til_publish)
  end

  game_day = Time.new +
             (days_til_publish + days_btwn_publish_game) * TimeDate::DAY_TO_SEC

  "#{game_day.year}-#{game_day.mon}-#{game_day.day} "\
  "#{scheduled_game.start_time.hour}"
end

def url_error_for_group_need_permission
  if !valid_group_id?
    handle_invalid_group_id
  elsif !@group.id
    handle_group_not_found
  elsif !group_have_permission?
    handle_group_no_permission
  end
end

def url_error_for_schedule_day
  if !valid_schedule_day?
    handle_invalid_schedule_day
  end
end

def input_error_for_post_schedule
  if !valid_schedule_day?
    handle_invalid_schedule_day
  end
end

def input_error_for_group_schedule
  if !valid_group_notes?
    handle_invalid_group_notes
  end
end
