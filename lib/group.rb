class Group
  attr_accessor :name, :about
  attr_reader :id, :organizers

  def initialize(id, name, about)
    self.id = id
    self.name = name
    self.about = about
    self.organizers = []
  end

  def add_organizer

  end

  def remove_organizer

  end

  private

  attr_writer :id, :organizers
end
