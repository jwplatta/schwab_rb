require 'oauth2'

module SchwabRb::Auth
  def self.from_token_file(api_key, app_secret, token_path, enforce_enums: true)
    oauth = OAuth2::Client.new(
      api_key,
      app_secret,
      site: SchwabRb::Constants::SCHWAB_BASE_URL,
      token_url: "/v1/oauth/token"
    )

    metadata_manager = SchwabRb::Auth::TokenManager.from_file(token_path)
    token = metadata_manager.token

    session = OAuth2::AccessToken.new(
      oauth,
      token.token,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at
    )

    SchwabRb::Client.new(
      api_key,
      session,
      token_manager: metadata_manager,
      enforce_enums: enforce_enums
    )
  end
end
