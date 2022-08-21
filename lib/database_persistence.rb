require "pg"

class DatabasePersistence
  def initialize(logger = nil)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          elsif Sinatra::Base.test?
            PG.connect(dbname: "bad_buds_test")
          else
            PG.connect(dbname: "bad_buds")
          end
    @logger = logger
  end

  def find_game_sql_query
    <<~SQL
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
            template
        FROM games AS gm
            LEFT JOIN games_players AS g_p
            ON gm.id = g_p.game_id
            LEFT JOIN groups AS gp
            ON gm.group_id = gp.id
      WHERE gm.id = $1
      ORDER BY start_time ASC;
    SQL
  end

  def find_game(id)
    result = query(find_game_sql_query, id)
    tuple = result.first

    return nil if result.ntuples.zero?

    players = find_players_for_game(id)
    filled_slots = players.count

    Game.new(id: tuple["id"].to_i,
             start_time: tuple["start_time"],
             duration: tuple["duration"].to_i,
             group_name: tuple["group_name"],
             group_id: tuple["group_id"].to_i,
             location: tuple["location"],
             level: tuple["level"],
             fee: tuple["fee"].to_i,
             filled_slots: filled_slots,
             total_slots: tuple["total_slots"].to_i,
             players: players,
             notes: tuple["notes"],
             template: (tuple["template"] == "t"))
  end

  def create_game_sql_query
    <<~SQL
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
  end

  def create_game(game)
    query(create_game_sql_query,
          game.group_id,
          game.start_time,
          game.duration,
          game.location,
          game.level,
          game.fee,
          game.total_slots,
          game.notes,
          game.template)
  end

  def edit_game_sql_query
    <<~SQL
      UPDATE games
        SET start_time = $2,
            duration = $3,
            location = $4,
            level = $5,
            total_slots = $6,
            fee = $7
      WHERE id = $1;
    SQL
  end

  def edit_game(game)
    query(edit_game_sql_query,
          game.id,
          game.start_time,
          game.duration,
          game.location,
          game.level,
          game.total_slots,
          game.fee)
  end

  def delete_game(id)
    sql = <<~SQL
      DELETE FROM games
       WHERE id = $1;
    SQL

    query(sql, id)
  end

  def find_group_games_sql_query
    <<~SQL
      SELECT gm.id,
            gm.start_time,
            gm.duration,
            gm.location,
            gp.id AS group_id,
            gm.fee,
            count(g_p.player_id) AS filled_slots,
            total_slots
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
  end

  def find_group_games(group_id)
    result = query(find_group_games_sql_query, group_id)

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

  def find_scheduled_games_sql_query
    <<~SQL
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
  end

  def find_scheduled_games(group_id)
    result = query(find_scheduled_games_sql_query, group_id)

    return [] if result.ntuples.zero?

    result.map do |tuple|
      players = find_players_for_game(tuple["id"].to_i)
      filled_slots = players.count

      Game.new(id: tuple["id"].to_i,
               start_time: tuple["start_time"],
               duration: tuple["duration"].to_i,
               group_name: tuple["group_name"],
               group_id: tuple["group_id"].to_i,
               location: tuple["location"],
               level: tuple["level"],
               fee: tuple["fee"].to_i,
               filled_slots: filled_slots,
               total_slots: tuple["total_slots"].to_i,
               players: players,
               notes: tuple["notes"],
               template: false)
    end
  end

  def all_games_sql_query
    <<~SQL
      SELECT gm.id,
            gm.start_time,
            gm.duration,
            gm.location,
            gp.name AS group_name,
            gp.id AS group_id,
            gm.fee,
            count(g_p.player_id) AS filled_slots,
            total_slots
        FROM games AS gm
            LEFT JOIN games_players AS g_p
            ON gm.id = g_p.game_id
            LEFT JOIN groups AS gp
            ON gm.group_id = gp.id
      GROUP BY gm.id, gp.id
      HAVING gm.template = FALSE
      ORDER BY start_time ASC;
    SQL
  end

  def all_games
    result = query(all_games_sql_query)

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

  def find_group_template_games_for_day_sql_query
    <<~SQL
      SELECT games.*,
             count(games_players.player_id) AS filled_slots
        FROM games
             LEFT JOIN games_players
             ON games.id = games_players.game_id
       WHERE group_id = $1 AND
             template = TRUE AND
             extract(DOW FROM start_time) = $2
       GROUP BY games.id;
    SQL
  end

  def find_group_template_games_for_day(group_id, day_of_week)
    result = query(find_group_template_games_for_day_sql_query,
                   group_id,
                   day_of_week)

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
               total_slots: tuple["total_slots"].to_i,
               template: tuple["template"] == "t")
    end
  end

  def all_groups_sql_query
    <<~SQL
      SELECT *
        FROM groups;
    SQL
  end

  def all_groups
    result = query(all_groups_sql_query)

    result.map do |tuple|
      Group.new(id: tuple["id"],
                name: tuple["name"],
                about: tuple["about"],
                schedule_game_notes: tuple["schedule_game_notes"])
    end
  end

  def find_player_sql_query
    <<~SQL
      SELECT *
        FROM players
      WHERE id = $1;
    SQL
  end

  def find_player(id)
    result = query(find_player_sql_query, id)
    tuple = result.first

    return nil if result.ntuples.zero?

    Player.new(id: tuple["id"],
               username: tuple["username"],
               password: tuple["password"],
               name: tuple["name"],
               rating: tuple["rating"],
               about: tuple["about"])
  end

  def edit_player(player)
    sql = <<~SQL
      UPDATE players
         SET password = $2,
             name = $3,
             rating = $4,
             about = $5
       WHERE id = $1;
    SQL

    query(sql,
          player.id,
          player.password,
          player.name,
          player.rating,
          player.about)
  end

  def delete_group(group_id)
    sql = <<~SQL
      DELETE FROM groups
       WHERE id = $1;
    SQL

    query(sql, group_id)
  end

  def find_group_sql_query
    <<~SQL
      SELECT *
        FROM groups
      WHERE id = $1;
    SQL
  end

  def find_group(id)
    result = query(find_group_sql_query, id)
    tuple = result.first

    return nil if result.ntuples.zero?

    Group.new(id: tuple["id"],
              name: tuple["name"],
              about: tuple["about"],
              schedule_game_notes: tuple["schedule_game_notes"])
  end

  def group_name_exists_sql_query
    <<~SQL
      SELECT *
        FROM groups
      WHERE name = $1;
    SQL
  end

  def group_name_exists?(name)
    !query(group_name_exists_sql_query, name).ntuples.zero?
  end

  def find_groups_is_organizer_sql_query
    <<~SQL
      SELECT groups.*
        FROM groups
             INNER JOIN groups_players
             ON groups_players.group_id = groups.id
       WHERE is_organizer = TRUE AND
             groups_players.player_id = $1;
    SQL
  end

  def find_groups_is_organizer(player_id)
    result = query(find_groups_is_organizer_sql_query, player_id)

    return [] if result.ntuples.zero?

    result.map do |group|
      Group.new(id: group["id"],
                name: group["name"],
                about: group["about"],
                schedule_game_notes: group["schedule_game_notes"])
    end
  end

  def last_group_id
    sql = <<~SQL
      SELECT last_value
        FROM groups_id_seq;
    SQL

    query(sql).first["last_value"].to_i
  end

  def edit_group_schedule_game_notes(group_id, notes)
    sql = <<~SQL
      UPDATE groups
         SET schedule_game_notes = $1
       WHERE id = $2;
    SQL

    query(sql, notes, group_id)
  end

  def find_group_players_sql_query
    <<~SQL
      SELECT *
        FROM groups
            INNER JOIN groups_players
            ON groups.id = groups_players.group_id
            INNER JOIN players
            ON groups_players.player_id = players.id
      WHERE groups.id = $1
      ORDER BY is_organizer DESC;
    SQL
  end

  def find_group_players(id)
    result = query(find_group_players_sql_query, id)

    result.map do |player|
      Player.new(id: player["id"].to_i,
                 username: player["username"],
                 password: player["password"],
                 name: player["name"],
                 rating: player["rating"].to_i,
                 about: player["about"],
                 fee_paid: player["fee_paid"] == 't',
                 is_organizer: player["is_organizer"] == 't')
    end
  end

  def add_player(player)
    sql = <<~SQL
      INSERT INTO players (username, password, name, rating, about)
      VALUES ($1, $2, $3, $4, $5);
    SQL

    query(sql,
          player.username,
          player.password,
          player.name,
          player.rating,
          player.about)
  end

  def add_group(group)
    sql = <<~SQL
      INSERT INTO groups (id, name, about)
      VALUES ($1, $2, $3)
    SQL

    new_group_id = if group.id.nil?
                     'DEFAULT'
                   else
                     group.id
                   end

    query(sql, new_group_id, group.name, group.about)

    if new_group_id != 'DEFAULT'
      query("SELECT nextval('groups_id_seq');")
    end
  end

  def edit_group(group)
    sql = <<~SQL
      UPDATE groups
         SET name = $2,
             about = $3
       WHERE id = $1;
    SQL

    query(sql, group.id, group.name, group.about)
  end

  def make_organizer(group_id, player_id)
    sql = <<~SQL
      UPDATE groups_players
         SET is_organizer = TRUE
       WHERE group_id = $1 AND
             player_id = $2;
    SQL

    query(sql, group_id, player_id)
  end

  def remove_organizer(group_id, player_id)
    sql = <<~SQL
      UPDATE groups_players
         SET is_organizer = FALSE
       WHERE group_id = $1 AND
             player_id = $2;
    SQL

    query(sql, group_id, player_id)
  end

  def add_game(game)
    sql = <<~SQL
      INSERT INTO games (group_id, start_time, duration, location, fee,
                         total_slots, notes, template)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8);
    SQL

    query(sql,
          game.group_id,
          game.start_time,
          game.duration,
          game.location,
          game.fee,
          game.total_slots,
          game.notes,
          game.template)
  end

  def last_game_id
    sql = <<~SQL
      SELECT last_value
        FROM games_id_seq;
    SQL

    query(sql).first["last_value"].to_i
  end

  def rsvp_player(game_id, player_id)
    sql = <<~SQL
      INSERT INTO games_players (game_id, player_id)
      VALUES ($1, $2)
    SQL

    query(sql, game_id, player_id)
  end

  def un_rsvp_player(game_id, player_id)
    sql = <<~SQL
      DELETE FROM games_players
       WHERE game_id = $1 AND
             player_id = $2;
    SQL

    query(sql, game_id, player_id)
  end

  def add_anon_player_sql_query
    <<~SQL
      INSERT INTO players (name)
      VALUES ($1);
    SQL
  end

  def last_added_player_id_sql_query
    <<~SQL
      SELECT last_value
        FROM players_id_seq;
    SQL
  end

  def add_player_to_game_sql_query
    <<~SQL
      INSERT INTO games_players (player_id, game_id)
      VALUES ($1, $2)
    SQL
  end

  def rsvp_anon_player(game_id, player_name)
    query(add_anon_player_sql_query, player_name)

    result = query(last_added_player_id_sql_query)
    player_id = result.first["last_value"].to_i

    query(add_player_to_game_sql_query, player_id, game_id)
  end

  def already_signed_up?(game_id, player_id)
    sql = <<~SQL
      SELECT 1 FROM games_players
       WHERE game_id = $1 AND player_id = $2;
    SQL

    result = query(sql, game_id, player_id)

    !result.ntuples.zero?
  end

  def already_joined_group?(group_id, player_id)
    sql = <<~SQL
      SELECT 1 FROM groups_players
       WHERE group_id = $1 AND player_id = $2;
    SQL

    result = query(sql, group_id, player_id)

    !result.ntuples.zero?
  end

  def add_player_to_group(group_id, player_id)
    sql = <<~SQL
      INSERT INTO groups_players (group_id, player_id)
      VALUES ($1, $2);
    SQL

    query(sql, group_id, player_id)
  end

  def remove_player_from_group(group_id, player_id)
    sql = <<~SQL
      DELETE FROM groups_players
       WHERE group_id = $1 AND player_id = $2;
    SQL

    query(sql, group_id, player_id)
  end

  def group_organizer?(group_id, player_id)
    sql = <<~SQL
      SELECT is_organizer
        FROM groups_players
       WHERE group_id = $1 AND player_id = $2;
    SQL

    result = query(sql, group_id, player_id)
    return false if result.ntuples.zero?

    result.first["is_organizer"] == 't'
  end

  def game_organizer_sql_query
    <<~SQL
      SELECT is_organizer
        FROM games
            INNER JOIN groups_players
            ON games.group_id = groups_players.group_id
            INNER JOIN players
            ON groups_players.player_id = players.id
      WHERE games.id = $1 AND players.id = $2;
    SQL
  end

  def game_organizer?(game_id, player_id)
    result = query(game_organizer_sql_query, game_id, player_id)
    return false if result.ntuples.zero?

    result.first["is_organizer"] == 't'
  end

  def confirm_paid(game_id, player_id)
    sql = <<~SQL
      UPDATE games_players
         SET fee_paid = true
       WHERE game_id = $1 AND player_id = $2;
    SQL

    query(sql, game_id, player_id)
  end

  def confirm_all_paid(game_id)
    sql = <<~SQL
      UPDATE games_players
        SET fee_paid = true
      WHERE game_id = $1
    SQL

    query(sql, game_id)
  end

  def unconfirm_paid(game_id, player_id)
    sql = <<~SQL
      UPDATE games_players
         SET fee_paid = false
       WHERE game_id = $1 AND player_id = $2;
    SQL

    query(sql, game_id, player_id)
  end

  def unconfirm_all_paid(game_id)
    sql = <<~SQL
      UPDATE games_players
        SET fee_paid = false
      WHERE game_id = $1
    SQL

    query(sql, game_id)
  end

  def find_password(username)
    sql = <<~SQL
      SELECT password
        FROM players
       WHERE username = $1;
    SQL

    result = query(sql, username)
    return nil if result.ntuples.zero?

    result.first["password"]
  end

  def find_player_id(username)
    sql = <<~SQL
      SELECT id
        FROM players
       WHERE username = $1;
    SQL

    result = query(sql, username)
    return nil if result.ntuples.zero?

    result.first["id"]
  end

  def seed_data
    system("psql -d bad_buds_test < data.sql")
  end

  def delete_data
    query("DELETE FROM groups_players;")
    query("ALTER SEQUENCE groups_players_id_seq RESTART WITH 1;")
    query("DELETE FROM games_players;")
    query("ALTER SEQUENCE games_players_id_seq RESTART WITH 1;")
    query("DELETE FROM games;")
    query("ALTER SEQUENCE games_id_seq RESTART WITH 1;")
    query("DELETE FROM players;")
    query("ALTER SEQUENCE players_id_seq RESTART WITH 1;")
    query("DELETE FROM groups;")
    query("ALTER SEQUENCE groups_id_seq RESTART WITH 1;")
  end

  def disconnect
    @db.close
  end

  private

  def query(statement, *params)
    @logger&.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def find_players_for_game_sql_query
    <<~SQL
    SELECT players.id, name, rating, about, username, fee_paid
      FROM players
          INNER JOIN games_players
          ON games_players.player_id = players.id
    WHERE games_players.game_id = $1
    SQL
  end

  def find_players_for_game(game_id)
    result = query(find_players_for_game_sql_query, game_id)

    result.map do |tuple|
      fee_paid = (tuple["fee_paid"] == 't')

      Player.new(id: tuple["id"], name: tuple["name"], rating: tuple["rating"],
                 about: tuple["about"], username: tuple["username"],
                 fee_paid: fee_paid)
    end
  end
end
