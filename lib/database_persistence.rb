require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "bad_buds")
          end
    @logger = logger
  end

  def find_game(id)
    sql = <<~SQL
    SELECT gm.id,
           gm.start_time,
           gm.duration,
           gp.id AS group_id,
           gp.name AS group_name,
           l.name AS location,
           gm.fee,
           gm.total_slots,
           gm.notes
      FROM games AS gm
           INNER JOIN games_players AS g_p
           ON gm.id = g_p.game_id
           INNER JOIN groups AS gp
           ON gm.group_id = gp.id
           INNER JOIN locations as l
           ON gm.location_id = l.id
     WHERE gm.id = $1
     ORDER BY start_time ASC;
    SQL

    result = query(sql, id)
    tuple = result.first

    return nil if result.ntuples.zero?

    players = find_players_for_game(id)
    filled_slots = players.count

    Game.new(id: tuple["id"],
             start_time: tuple["start_time"],
             duration: tuple["duration"],
             group_name: tuple["group_name"],
             group_id: tuple["group_id"],
             location: tuple["location"],
             fee: tuple["fee"],
             filled_slots: filled_slots,
             total_slots: tuple["total_slots"],
             players: players,
             notes: tuple["notes"])
  end

  def find_group_games(group_id)
    sql = <<~SQL
    SELECT gm.id,
           gm.start_time,
           gm.duration,
           gp.id AS group_id,
           l.name AS location,
           gm.fee,
           count(g_p.player_id) AS filled_slots,
           total_slots
      FROM games AS gm
           INNER JOIN games_players AS g_p
           ON gm.id = g_p.game_id
           INNER JOIN groups AS gp
           ON gm.group_id = gp.id
           INNER JOIN locations as l
           ON gm.location_id = l.id
     WHERE gp.id = $1
     GROUP BY gm.id, gp.id, l.id
     ORDER BY start_time ASC;
    SQL

    result = query(sql, group_id)

    result.map do |tuple|
      Game.new(id: tuple["id"],
               start_time: tuple["start_time"],
               duration: tuple["duration"],
               group_name: tuple["group_name"],
               group_id: tuple["group_id"],
               location: tuple["location"],
               fee: tuple["fee"],
               filled_slots: tuple["filled_slots"],
               total_slots: tuple["total_slots"])
    end
  end

  def all_games
    sql = <<~SQL
      SELECT gm.id,
             gm.start_time,
             gm.duration,
             gp.name AS group_name,
             gp.id AS group_id,
             l.name AS location,
             gm.fee,
             count(g_p.player_id) AS filled_slots,
             total_slots
        FROM games AS gm
             INNER JOIN games_players AS g_p
             ON gm.id = g_p.game_id
             INNER JOIN groups AS gp
             ON gm.group_id = gp.id
             INNER JOIN locations as l
             ON gm.location_id = l.id
       GROUP BY gm.id, gp.id, l.id
       ORDER BY start_time ASC;
    SQL

    result = query(sql)

    result.map do |tuple|
      Game.new(id: tuple["id"],
               start_time: tuple["start_time"],
               duration: tuple["duration"],
               group_name: tuple["group_name"],
               group_id: tuple["group_id"],
               location: tuple["location"],
               fee: tuple["fee"],
               filled_slots: tuple["filled_slots"],
               total_slots: tuple["total_slots"])
    end
  end

  def all_groups
    sql = <<~SQL
      SELECT *
        FROM groups;
    SQL

    result = query(sql)

    result.map do |tuple|
      Group.new(tuple["id"],
                tuple["name"],
                tuple["about"])
    end
  end

  def find_player(id)
    sql = <<~SQL
      SELECT *
        FROM players
       WHERE id = $1;
    SQL

    result = query(sql, id)
    tuple = result.first

    return nil if result.ntuples.zero?

    Player.new(id: tuple["id"],
               name: tuple["name"],
               rating: tuple["rating"],
               games_played: tuple["games_played"],
               about: tuple["about"])
  end

  def find_group(id)
    sql = <<~SQL
      SELECT *
        FROM groups
       WHERE id = $1;
    SQL

    result = query(sql, id)
    tuple = result.first

    return nil if result.ntuples.zero?

    Group.new(tuple["id"],
              tuple["name"],
              tuple["about"])
  end

  def rsvp_anon_player(game_id, player_name)
    sql = <<~SQL
      INSERT INTO players (name)
      VALUES ($1);
    SQL

    result = query(sql, player_name)

    sql = <<~SQL
      SELECT last_value
        FROM players_id_seq;
    SQL

    result = query(sql)

    player_id = result.first["last_value"].to_i

    sql = <<~SQL
      INSERT INTO games_players (player_id, game_id)
      VALUES ($1, $2)
    SQL

    query(sql, player_id, game_id)
  end

  def disconnect
    @db.close
  end

  private

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def find_players_for_game(game_id)
    sql = "SELECT players.id, username, name, fee_paid
             FROM players
                  INNER JOIN games_players
                  ON games_players.player_id = players.id
            WHERE games_players.game_id = $1"

    result = query(sql, game_id)

    result.map do |tuple|
      fee_paid = if tuple["fee_paid"] == 't'
                   true
                 else
                   false
                 end

      Player.new(id: tuple["id"],
                 name: tuple["name"],
                 rating: tuple["rating"],
                 games_played: tuple["games_played"],
                 about: tuple["about"],
                 username: tuple["username"],
                 fee_paid: fee_paid)
    end
  end
end
