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

  def initialize(start_time: "2022-07-25 20:00:00",
                 duration: 0,
                 group_id: nil,
                 location: "",
                 level: 1,
                 fee: 0,
                 total_slots: 0,
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

  def create(db)
    sql = <<~SQL
      INSERT INTO games (group_id,
                        start_time,
                        duration,
                        location,
                        level,
                        fee,
                        total_slots,
                        notes,
                        template)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9);
    SQL

    db.query(sql,
             self.group_id,
             self.start_time,
             self.duration,
             self.location,
             self.level,
             self.fee,
             self.total_slots,
             self.notes,
             self.template)
  end

  def read(db)
    sql = <<~SQL
      SELECT gm.id,
             gm.start_time,
             gm.duration,
             gm.location,
             gm.level,
             gp.id AS group_id,
             gp.name AS group_name,
             gm.fee,
             gm.total_slots,
             gm.notes,
             gm.template
        FROM games AS gm
            LEFT JOIN games_players AS g_p
            ON gm.id = g_p.game_id
            LEFT JOIN groups AS gp
            ON gm.group_id = gp.id
      WHERE gm.id = $1
      ORDER BY start_time ASC;
    SQL

    result = db.query(sql, self.id)
    tuple = result.first

    if result.ntuples.zero?
      self.id = nil
      return nil
    end

    read_players(db)

    self.start_time = Time.parse(tuple["start_time"])
    self.duration = tuple["duration"].to_i
    self.group_name = tuple["group_name"]
    self.group_id = tuple["group_id"].to_i
    self.location = tuple["location"]
    self.level = tuple["level"]
    self.fee = tuple["fee"].to_i
    self.total_slots = tuple["total_slots"].to_i
    self.notes = tuple["notes"]
    self.template = tuple["template"] == "t"
  end

  def read_players(db)
    sql = <<~SQL
    SELECT players.id, name, rating, about, username, fee_paid
      FROM players
          INNER JOIN games_players
          ON games_players.player_id = players.id
    WHERE games_players.game_id = $1
    SQL

    result = db.query(sql, self.id)

    players = result.map do |tuple|
      fee_paid = (tuple["fee_paid"] == 't')

      Player.new(id: tuple["id"].to_i,
                 name: tuple["name"],
                 rating: tuple["rating"].to_i,
                 about: tuple["about"],
                 username: tuple["username"],
                 fee_paid: fee_paid)
    end

    self.players = players
    self.filled_slots = players.count

    return players
  end

  def update(db)
    sql = <<~SQL
    UPDATE games
      SET start_time = $2,
          duration = $3,
          location = $4,
          level = $5,
          total_slots = $6,
          fee = $7,
          notes = $8
    WHERE id = $1;
  SQL

    db.query(sql,
             self.id,
             self.start_time,
             self.duration,
             self.location,
             self.level,
             self.total_slots,
             self.fee,
             self.notes)
  end


  def delete(db)
    sql = <<~SQL
      DELETE FROM games
       WHERE id = $1;
    SQL

    db.query(sql, self.id)
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
