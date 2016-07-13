require "logger"
require "pg"
require "pool/connection"

class Corm
  module Runner
    extend self

    @@pool : ConnectionPool(PG::Connection) | Nil
    @@logger : Logger | Nil

    def pool
      @@pool ||= ConnectionPool.new(capacity: 25, timeout: 0.01) do
        PG.connect(ENV["PG_URL"])
      end
    end

    def log_file=(path)
      io = File.open(File.expand_path(path), "a")
      @@logger ||= Logger.new(io)
    end

    def logger
      @@logger ||= Logger.new(STDOUT)
    end

    def self.run_with_connection
      connection = pool.checkout
      result = yield connection
      pool.checkin connection
      result
    end

    def self.run(query : String, args = [] of PG::PGValue)
      logger.info "Running query: #{query}"
      run_with_connection do |connection|
        connection.exec query, args
      end
    end

    def self.run(types, query : String, args = [] of PG::PGValue)
      logger.info "Running query: #{query}"
      run_with_connection do |connection|
        connection.exec types, query, args
      end
    end
  end
end
