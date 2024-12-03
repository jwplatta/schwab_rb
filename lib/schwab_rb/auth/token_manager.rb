module SchwabRb::Auth
  class TokenManager
    def initialize(token, timestamp, token_path: "./schwab_token.json")
      @token = token
      @timestamp = timestamp
      @token_path = token_path
    end

    attr_reader :token, :timestamp, :token_path

    def to_file
      File.open(token_path, "w") do |f|
        f.write(to_json)
      end
    end

    def token_age
      Time.now.to_i - timestamp
    end

    def to_h
      token_data = {
        timestamp: timestamp,
        token: {
          expires_in: token.expires_in,
          token_type: token.params["token_type"] || "Bearer",
          scope: token.params["scope"],
          refresh_token: token.refresh_token,
          access_token: token.token,
          id_token: token.params["id_token"],
          expires_at: token.expires_at
        }
      }
    end

    def to_json
      to_h.to_json
    end
  end
end
