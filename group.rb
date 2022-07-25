class Group
  attr_accessor name, about, organizers

  def initialize(name, about)
    self.name = name
    self.about = about
    self.organizers = []
  end

  def add_organizer

  end

  def remove_organizer
    
  end

  private

  attr_writer organizers
end
