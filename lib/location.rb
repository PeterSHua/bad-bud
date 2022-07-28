class Location
  attr_reader :id, :name, :address, :phone_number, :cost_per_court

  def initialize(id:, name:, address:, phone_number:, cost_per_court:)
    self.id = id,
    self.name = name,
    self.address = address,
    self.phone_number = phone_number,
    self.cost_per_court = cost_per_court
  end

  private

  attr_writer :id, :name, :address, :phone_number, :cost_per_court
end
