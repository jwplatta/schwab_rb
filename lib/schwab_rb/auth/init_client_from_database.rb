# frozen_string_literal: true

require "oauth2"

module SchwabRb
  module Auth
    def self.init_client_from_database(api_key, app_secret, enforce_enums: true, database: nil)
      metadata_manager = SchwabRb::Auth::TokenManager.from_database(api_key, database: database)
      return nil unless metadata_manager

      token = metadata_manager.token

      oauth = OAuth2::Client.new(
        api_key,
        app_secret,
        site: SchwabRb::Constants::SCHWAB_BASE_URL,
        token_url: "/v1/oauth/token"
      )

      session = OAuth2::AccessToken.new(
        oauth,
        token.token,
        refresh_token: token.refresh_token,
        expires_at: token.expires_at
      )

      SchwabRb::Client.new(
        api_key,
        app_secret,
        session,
        token_manager: metadata_manager,
        enforce_enums: enforce_enums
      )
    end
  end
end
