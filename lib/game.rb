require "time"

MONTHS = %w(Jan Feb Mar Apr May Jun Jul Aug Sept Oct Nov Dec)
DAYS_OF_WEEK = %w(Sun Mon Tues Wed Thurs Fri Sat)

class Game
  attr_accessor :start_time, :duration, :group, :location, :fee, :filled_slots, :total_slots
  attr_reader :players

  def initialize(start_time,
                duration,
                group,
                location,
                fee,
                filled_slots,
                total_slots)

    self.start_time = Time.parse(start_time)
    self.duration = duration
    self.group = group
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
