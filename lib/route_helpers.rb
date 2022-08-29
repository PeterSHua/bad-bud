def https_required
  return unless settings.production? && request.scheme == 'http'

  headers['Location'] = request.url.sub('http', 'https')
  halt 301
end

def force_login
  return unless !already_logged_in?

  session[:error] = "You must be logged in to do that."
  redirect "/game_list"
end
