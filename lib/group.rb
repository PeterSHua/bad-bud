class Group
  MIN_NAME_LEN = 1
  MAX_NAME_LEN = 50
  MIN_ABOUT_LEN = 0
  MAX_ABOUT_LEN = 1000
  MIN_SCHEDULE_NOTES = 0
  MAX_SCHEDULE_NOTES = 1000

  attr_reader :id, :name, :about, :schedule_game_notes

  def initialize(id:, name: "", about: "", schedule_game_notes: "")
    self.id = id
    self.name = name
    self.about = about
    self.schedule_game_notes = schedule_game_notes
  end

  private

  attr_writer :id, :name, :about, :schedule_game_notes
end
