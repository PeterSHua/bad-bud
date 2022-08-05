class Group
  attr_reader :id, :name, :about, :schedule_game_notes

  def initialize(id:, name:, about:, schedule_game_notes:)
    self.id = id
    self.name = name
    self.about = about
    self.schedule_game_notes = schedule_game_notes
  end

  attr_writer :id, :name, :about, :schedule_game_notes
end
