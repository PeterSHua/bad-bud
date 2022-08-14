class BadBudsTest < Minitest::Test
  # rubocop: disable Metrics/MethodLength
  # rubocop: disable Metrics/AbcSize
  def test_login
    get "/login"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Username"
    assert_includes last_response.body, "Password"

    post "/login", { username: "david", password: "abc123" }

    assert_equal 302, last_response.status
    assert_equal "Welcome!", session[:success]
    assert_equal "david", session[:username]
    assert_equal "2", session[:player_id]
    assert session[:logged_in]

    get last_response["Location"]
    assert_includes last_response.body, "&#128075;david"
  end
  # rubocop: enable Metrics/MethodLength
  # rubocop: enable Metrics/AbcSize

  def test_login_fail
    post "/login", { username: "groucho", password: "marx" }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "Invalid Credentials!"
    refute session[:logged_in]
  end

  def test_logout
    post "/login", { username: "david", password: "abc123" }
    get last_response["Location"]

    assert_includes last_response.body, "Sign Out"

    post "/logout"

    assert_equal 302, last_response.status
    assert_equal "You have been signed out.", session[:success]

    get last_response["Location"]

    assert_equal 200, last_response.status
    refute_equal "Welcome!", session[:success]
    refute_equal "david", session[:username]
    refute_equal "1", session[:player_id]
    refute session[:logged_in]

    assert_includes last_response.body, "Sign In"
  end

  def test_register
    post "/register", { username: "groucho", password: "marx" }
    get last_response["Location"]

    assert_includes last_response.body, "&#128075;groucho"

    post "/logout"

    assert_equal 302, last_response.status
    assert_equal "You have been signed out.", session[:success]

    get last_response["Location"]

    assert_equal 200, last_response.status
    refute session[:logged_in]
    assert_includes last_response.body, "Sign In"
  end

  def test_register_already_logged_in
    post "/register",
         { username: "harpo", password: "marx" },
         logged_in_as_david

    assert_equal 302, last_response.status
    assert_equal "You're already logged in.", session[:error]
  end

  def test_register_acc_exists
    post "/register", { username: "david", password: "abc123" }

    assert_equal 422, last_response.status
    assert_includes last_response.body, "That account name already exists."
  end

  def test_register_short_username
    post "/register", { username: "gro", password: "marx" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Username must consist of only letters and numbers, "\
                    "and must be between 4-10 characters."
  end

  def test_register_long_username
    post "/register", { username: "groucho1234", password: "marx" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Username must consist of only letters and numbers, "\
                    "and must be between 4-10 characters."
  end

  def test_register_invalid_chars_username
    post "/register", { username: "gr[]ucho", password: "marx" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Username must consist of only letters and numbers, "\
                    "and must be between 4-10 characters."
  end

  def test_register_short_password
    post "/register", { username: "groucho", password: "mar" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Password must be between 4-10 characters and cannot "\
                    "contain spaces."
  end

  def test_register_long_password
    post "/register", { username: "groucho", password: "marx1234567" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Password must be between 4-10 characters and cannot "\
                    "contain spaces."
  end

  def test_register_invalid_chars_password
    post "/register", { username: "groucho", password: "m a r x" }

    assert_equal 422, last_response.status
    assert_includes last_response.body,
                    "Password must be between 4-10 characters and cannot "\
                    "contain spaces."
  end
end
