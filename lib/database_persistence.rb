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

  def all_games
    sql = <<~SQL
      SELECT gm.start_time,
             gm.duration,
             gp.name AS group,
             l.name AS location,
             gm.fee,
             count(g_p.player_id) AS filled_slots, total_slots
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
      Game.new(tuple["start_time"],
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
end
