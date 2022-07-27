class Player
  attr_reader :id, :username, :password, :name, :rating, :games_played, :about,
              :fee_paid

  def initialize(id:, name:, rating:, games_played:, about:, username: nil,
                 password: nil, fee_paid: false)
    self.id = id
    self.username = username
    self.password = password
    self.name = name
    self.rating = rating
    self.games_played = games_played
    self.about = about
    self.fee_paid = fee_paid
  end

  private

  attr_writer :id, :username, :password, :name, :rating, :games_played, :about,
              :fee_paid
end
