class Player
  attr_accessor name, rating, games_played, about

  def initialize(name, rating, games_played, about)
    self.name = name
    self.rating = rating
    self.games_played games_played
    self.about = about
  end

  private
end
