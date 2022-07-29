class Group
  attr_reader :id, :name, :about

  def initialize(id:, name:, about:)
    self.id = id
    self.name = name
    self.about = about
  end

  attr_writer :id, :name, :about
end
