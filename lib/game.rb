class Game
  attr_accessor :date, :time, :duration, :location, :fee, :filled_slots, :total_slots
  attr_reader :players

  def initialize(date, time, duration, location, fee, filled_slots, total_slots)
    self.date = date
    self.time = time
    self.duration = duration
    self.location = location
    self.fee = fee
    self.filled_slots = filled_slots
    self.total_slots = total_slots

    self.players = {} # player: boolean -> true = paid
  end

  def add_player

  end

  def remove_player

  end

  private

  attr_writer :players
end
