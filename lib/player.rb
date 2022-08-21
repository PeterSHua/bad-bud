class Player
  MIN_RATING = 1
  MAX_RATING = 6
  MAX_USERNAME_LEN = 10
  MIN_USERNAME_LEN = 4
  MAX_PASS_LEN = 10
  MIN_PASS_LEN = 4
  MIN_NAME_LEN = 1
  MAX_NAME_LEN = 20
  MAX_ABOUT_LEN = 300

  attr_reader :id,
              :username,
              :password,
              :name,
              :rating,
              :about,
              :fee_paid,
              :is_organizer

  def initialize(id: 0,
                 name: "Anonymous",
                 rating: 1,
                 about: "",
                 username: "",
                 password: "",
                 fee_paid: false,
                 is_organizer: false)

    self.id = id
    self.username = username
    self.password = password
    self.name = name
    self.rating = rating
    self.about = about
    self.fee_paid = fee_paid
    self.is_organizer = is_organizer
  end

  private

  attr_writer :id,
              :username,
              :password,
              :name,
              :rating,
              :games_played,
              :about,
              :fee_paid,
              :is_organizer
end
