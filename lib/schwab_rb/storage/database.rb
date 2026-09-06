# frozen_string_literal: true

require "sqlite3"

module SchwabRb
  module Storage
    class Database
      attr_reader :path

      def initialize(path = nil)
        @path = path || SchwabRb.configuration.database_path
        @mutex = Mutex.new
        @db = nil
      end

      def save_token(api_key, token_hash)
        synchronize do
          db.execute("DELETE FROM tokens WHERE api_key = ?", [api_key])
          db.execute(<<~SQL, bind_token_params(api_key, token_hash))
            INSERT INTO tokens (api_key, access_token, refresh_token, expires_at, expires_in,
                                token_type, scope, id_token, timestamp)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          SQL
        end
      end

      def load_token(api_key)
        row = synchronize do
          db.get_first_row("SELECT * FROM tokens WHERE api_key = ?", [api_key])
        end
        return nil unless row

        expires_at = row["expires_at"]
        if expires_at && Time.now.to_i > expires_at
          synchronize { db.execute("DELETE FROM tokens WHERE api_key = ?", [api_key]) }
          return nil
        end

        {
          "timestamp" => row["timestamp"],
          "token" => {
            "access_token" => row["access_token"],
            "refresh_token" => row["refresh_token"],
            "expires_at" => expires_at,
            "expires_in" => row["expires_in"],
            "token_type" => row["token_type"],
            "scope" => row["scope"],
            "id_token" => row["id_token"]
          }
        }
      end

      def close
        synchronize do
          @db&.close
          @db = nil
        end
      end

      private

      def db
        @db ||= open_database
      end

      def open_database
        is_memory = @path == ":memory:"
        SchwabRb::PathSupport.ensure_parent_directory(@path) unless is_memory

        database = SQLite3::Database.new(@path)
        database.results_as_hash = true
        database.execute("PRAGMA journal_mode=WAL") unless is_memory
        database.execute("PRAGMA foreign_keys=ON")
        create_tables(database)
        database
      end

      def create_tables(database)
        database.execute(<<~SQL)
          CREATE TABLE IF NOT EXISTS tokens (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            api_key TEXT NOT NULL UNIQUE,
            access_token TEXT,
            refresh_token TEXT,
            expires_at INTEGER,
            expires_in INTEGER,
            token_type TEXT DEFAULT 'Bearer',
            scope TEXT,
            id_token TEXT,
            timestamp INTEGER,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        SQL

      end

      def synchronize(&block)
        @mutex.synchronize(&block)
      end

      def bind_token_params(api_key, token_hash)
        token = token_hash["token"] || token_hash[:token] || {}
        [
          api_key,
          token["access_token"] || token[:access_token],
          token["refresh_token"] || token[:refresh_token],
          token["expires_at"] || token[:expires_at],
          token["expires_in"] || token[:expires_in],
          token["token_type"] || token[:token_type] || "Bearer",
          token["scope"] || token[:scope],
          token["id_token"] || token[:id_token],
          token_hash["timestamp"] || token_hash[:timestamp]
        ]
      end

    end
  end
end
