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

  def create(db)
    sql = <<~SQL
      INSERT INTO groups (id, name, about)
      VALUES ($1, $2, $3)
    SQL

    db.query(sql, self.id, self.name, self.about)
    db.query("SELECT setval('groups_id_seq', $1);", self.id)
  end

  def read_games(db)
    sql = <<~SQL
    SELECT gm.id,
           gm.start_time,
           gm.duration,
           gm.location,
           gp.id AS group_id,
           gm.fee,
           count(g_p.player_id) AS filled_slots,
           gm.total_slots
      FROM games AS gm
          LEFT JOIN games_players AS g_p
          ON gm.id = g_p.game_id
          INNER JOIN groups AS gp
          ON gm.group_id = gp.id
    WHERE gp.id = $1
    GROUP BY gm.id, gp.id
    HAVING gm.template = FALSE
    ORDER BY start_time ASC;
    SQL

    result = db.query(sql, self.id)

    result.map do |tuple|
      Game.new(id: tuple["id"].to_i,
               start_time: tuple["start_time"],
               duration: tuple["duration"].to_i,
               group_name: tuple["group_name"],
               group_id: tuple["group_id"].to_i,
               location: tuple["location"],
               level: tuple["level"],
               fee: tuple["fee"].to_i,
               filled_slots: tuple["filled_slots"].to_i,
               total_slots: tuple["total_slots"].to_i)
    end
  end

  def read_scheduled_games(db)
    sql = <<~SQL
    SELECT gm.id,
           gm.start_time,
           gm.duration,
           gm.location,
           gp.name AS group_name,
           gp.id AS group_id,
           gm.fee,
           total_slots
      FROM games as gm
           LEFT JOIN games_players AS g_p
           ON gm.id = g_p.game_id
           INNER JOIN groups AS gp
           ON gm.group_id = gp.id
    GROUP BY gm.id, gp.id
    HAVING gm.template = TRUE AND gp.id = $1
    ORDER BY start_time ASC;
    SQL

    result = db.query(sql, self.id)

    return [] if result.ntuples.zero?

    result.map do |tuple|
      game = Game.new(id: tuple["id"].to_i,
               start_time: tuple["start_time"],
               duration: tuple["duration"].to_i,
               group_name: tuple["group_name"],
               group_id: tuple["group_id"].to_i,
               location: tuple["location"],
               level: tuple["level"],
               fee: tuple["fee"].to_i,
               total_slots: tuple["total_slots"].to_i,
               notes: tuple["notes"],
               template: false)

      game.read_players(db)

      game
    end
  end

  def update(db)
    sql = <<~SQL
      UPDATE groups
         SET name = $2,
             about = $3
       WHERE id = $1;
    SQL

    db.query(sql, self.id, self.name, self.about)
  end

  def delete(db)
    sql = <<~SQL
      DELETE FROM groups
       WHERE id = $1;
    SQL

    db.query(sql, self.id)
  end

  private

  attr_writer :id, :name, :about, :schedule_game_notes
end
