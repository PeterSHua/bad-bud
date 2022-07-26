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
      SELECT games
    SQL

    result = query(sql)
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
