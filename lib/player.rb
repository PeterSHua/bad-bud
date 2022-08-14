class Player
  attr_reader :id,:username, :password, :name, :rating, :about,
              :fee_paid, :is_organizer

  def initialize(id: 0, name: "Anonymous", rating: 1, about: "", username: "",
                 password: "", fee_paid: false, is_organizer: false)

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

  attr_writer :id, :username, :password, :name, :rating, :games_played, :about,
              :fee_paid, :is_organizer
end
