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
           gp.name AS group,
           l.name AS location,
           gm.fee,
           p.name,
           total_slots
      FROM games AS gm
           INNER JOIN games_players AS g_p
           ON gm.id = g_p.game_id
           INNER JOIN groups AS gp
           ON gm.group_id = gp.id
           INNER JOIN locations as l
           ON gm.location_id = l.id
           INNER JOIN players AS p
           ON g_p.player_id = p.id
     WHERE gm.id = $1
     ORDER BY start_time ASC;
    SQL

    result = query(sql, id)
    tuple = result.first
    players = find_players_for_game(id)
    filled_slots = players.count

    Game.new(tuple["id"],
             tuple["start_time"],
             tuple["duration"],
             tuple["group"],
             tuple["location"],
             tuple["fee"],
             filled_slots,
             tuple["total_slots"],
             players)
  end

  def all_games
    sql = <<~SQL
      SELECT gm.id,
             gm.start_time,
             gm.duration,
             gp.name AS group,
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
       GROUP BY gm.id, gp.name, l.name
       ORDER BY start_time ASC;
    SQL

    result = query(sql)

    result.map do |tuple|
      Game.new(tuple["id"],
               tuple["start_time"],
               tuple["duration"],
               tuple["group"],
               tuple["location"],
               tuple["fee"],
               tuple["filled_slots"],
               tuple["total_slots"])
    end
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
    sql = "SELECT name, fee_paid
             FROM players
                  INNER JOIN games_players
                  ON games_players.player_id = players.id
            WHERE games_players.game_id = $1"

    result = query(sql, game_id)

    result.map do |player|
      fee_paid = if player["fee_paid"] == 't'
                   true
                 else
                   false
                 end

      { name: player["name"], fee_paid: fee_paid }
    end
  end
end
