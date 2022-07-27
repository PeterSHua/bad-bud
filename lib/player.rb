class Player
  attr_accessor :id, :name, :rating, :games_played, :about, :fee_paid

  def initialize(id, name, rating, games_played, about, fee_paid = false)
    self.id = id
    self.name = name
    self.rating = rating
    self.games_played = games_played
    self.about = about
    self.fee_paid = fee_paid
  end

  private
end
