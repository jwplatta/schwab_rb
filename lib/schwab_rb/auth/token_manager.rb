require 'oauth2'
require 'json'

module SchwabRb::Auth
  class TokenManager
    class << self
      def from_file(token_path)
        token_data = JSON.parse(File.read(token_path))
        token = SchwabRb::Auth::Token.new(
          token: token_data["token"]["access_token"],
          expires_in: token_data["token"]["expires_in"],
          token_type: token_data["token"]["token_type"],
          scope: token_data["token"]["scope"],
          refresh_token: token_data["token"]["refresh_token"],
          id_token: token_data["token"]["id_token"],
          expires_at: token_data["token"]["expires_at"]
        )

        TokenManager.new(token, token_data["timestamp"], token_path: token_path)
      end

      def from_oauth2_token(oauth2_token, timestamp, token_path: SchwabRb::Constants::DEFAULT_TOKEN_PATH)
        token = SchwabRb::Auth::Token.new(
          token: oauth2_token.token,
          expires_in: oauth2_token.expires_in,
          token_type: oauth2_token.params["token_type"] || "Bearer",
          scope: oauth2_token.params["scope"],
          refresh_token: oauth2_token.refresh_token,
          id_token: oauth2_token.params["id_token"],
          expires_at: oauth2_token.expires_at
        )

        TokenManager.new(token, timestamp, token_path: token_path)
      end
    end

    def initialize(token, timestamp, token_path: SchwabRb::Constants::DEFAULT_TOKEN_PATH)
      @token = token
      @timestamp = timestamp
      @token_path = token_path
    end

    attr_reader :token, :timestamp, :token_path

    def refresh_token(client)
      new_token = client.session.refresh!

      @token = SchwabRb::Auth::Token.new(
        token: new_token.token,
        expires_in: new_token.expires_in,
        token_type: new_token.params["token_type"] || "Bearer",
        scope: new_token.params["scope"],
        refresh_token: new_token.refresh_token,
        id_token: new_token.params["id_token"],
        expires_at: new_token.expires_at
      )
      @timestamp = Time.now.to_i

      to_file

      oauth = OAuth2::Client.new(
        client.api_key,
        client.app_secret,
        site: SchwabRb::Constants::SCHWAB_BASE_URL,
        token_url: "/v1/oauth/token"
      )

      OAuth2::AccessToken.new(
        oauth,
        token.token,
        refresh_token: token.refresh_token,
        expires_at: token.expires_at
      )
    end

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
          token_type: token.token_type,
          scope: token.scope,
          refresh_token: token.refresh_token,
          access_token: token.token,
          id_token: token.id_token,
          expires_at: token.expires_at
        }
      }
    end

    def to_json
      to_h.to_json
    end
  end
end
