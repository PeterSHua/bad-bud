class Game
  MIN_SLOTS = 1
  MAX_SLOTS = 1000
  MIN_FEE = 0
  MAX_FEE = 1000
  MIN_NOTE_LEN = 0
  MAX_NOTE_LEN = 1000
  MIN_LOCATION_LEN = 1
  MAX_LOCATION_LEN = 300
  MIN_LEVEL_LEN = 1
  MAX_LEVEL_LEN = 300

  attr_reader :id,
              :start_time,
              :duration,
              :group_name,
              :group_id,
              :location,
              :level,
              :fee,
              :filled_slots,
              :total_slots,
              :players,
              :notes,
              :template

  def initialize(start_time:,
                 duration:,
                 group_id:,
                 location:,
                 level:,
                 fee:,
                 total_slots:,
                 id: nil,
                 group_name: "",
                 players: {},
                 filled_slots: 0,
                 notes: "",
                 template: false)

    self.id = id
    self.start_time = Time.parse(start_time)
    self.duration = duration
    self.group_name = group_name
    self.group_id = group_id
    self.location = location
    self.level = level
    self.fee = fee
    self.filled_slots = filled_slots
    self.total_slots = total_slots
    self.players = players
    self.notes = notes
    self.template = template
  end

  private

  attr_writer :id,
              :start_time,
              :duration,
              :group_name,
              :group_id,
              :location,
              :level,
              :fee,
              :filled_slots,
              :total_slots,
              :players,
              :notes,
              :template
end
