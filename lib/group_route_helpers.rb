def no_group_selected?
  params[:group_id].empty?
end

def valid_group_id?
  params[:group_id].to_i.to_s == params[:group_id]
end

def handle_invalid_group_id
  session[:error] = "Invalid group."
end

def handle_group_not_found
  session[:error] = "The specified group was not found."
end

def group_have_permission?
  session[:logged_in] &&
    @storage.group_organizer?(@group_id, session[:player_id])
end

def handle_group_no_permission
  session[:error] = "You don't have permission to do that!"
end


def error_for_group_no_permission
  if !valid_group_id?
    handle_invalid_group_id
  elsif !@group.id
    handle_group_not_found
  end
end

def error_for_edit_group
  if !valid_group_id?
    handle_invalid_group_id
  elsif !@group.id
    handle_group_not_found
  elsif !group_have_permission?
    handle_group_no_permission
  end
end

def input_error_for_group
  if !valid_group_name?
    handle_invalid_group_name
  elsif group_exists?
    handle_group_already_exists
  elsif !valid_group_about?
    handle_invalid_group_about
  end
end

def input_error_for_edit_group
  if !valid_group_name?
    handle_invalid_group_name
  elsif !valid_group_about?
    handle_invalid_group_about
  end
end
