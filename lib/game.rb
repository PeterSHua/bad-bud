require "time"

MONTHS = %w(Jan Feb Mar Apr May Jun Jul Aug Sept Oct Nov Dec)
DAYS_OF_WEEK = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
DAY_TO_SEC = 86400

class Game
  attr_reader :id, :start_time, :duration, :group_name, :group_id, :location,
              :fee, :filled_slots, :total_slots, :players, :notes, :template

  def initialize(id: nil, start_time:, duration:, group_name:, group_id:,
                 location:, fee:, filled_slots: 0, total_slots:, players: {},
                 notes: "", template: false)

    self.id = id;
    self.start_time = Time.parse(start_time)
    self.duration = duration
    self.group_name = group_name
    self.group_id = group_id
    self.location = location
    self.fee = fee
    self.filled_slots = filled_slots
    self.total_slots = total_slots
    self.players = players
    self.notes = notes
    self.template = template
  end

  private

  attr_writer :id, :start_time, :duration, :group_name, :group_id, :location,
              :fee, :filled_slots, :total_slots, :players, :notes, :template
end
