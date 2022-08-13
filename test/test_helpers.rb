def session
  last_request.env["rack.session"]
end

def logged_in_as_david
  {
    "rack.session" => { logged_in: true,
                        username: "david",
                        player_id: 2 }
  }
end

def logged_in_as_peter
  {
    "rack.session" => { logged_in: true,
                        username: "peter",
                        player_id: 1 }
  }
end
