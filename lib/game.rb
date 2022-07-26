require "time"

MONTHS = %w(Jan Feb Mar Apr May Jun Jul Aug Sept Oct Nov Dec)
DAYS_OF_WEEK = %w(Sun Mon Tues Wed Thurs Fri Sat)

class Game
  attr_accessor :start_time, :duration, :group, :location, :fee, :filled_slots, :total_slots
  attr_reader :id, :players

  def initialize(id,
                start_time,
                duration,
                group,
                location,
                fee,
                filled_slots,
                total_slots,
                players = {})

    self.id = id;
    self.start_time = Time.parse(start_time)
    self.duration = duration
    self.group = group
    self.location = location
    self.fee = fee
    self.filled_slots = filled_slots
    self.total_slots = total_slots
    self.players = players
  end

  def add_player

  end

  def remove_player

  end

  private

  attr_writer :id, :players
end
