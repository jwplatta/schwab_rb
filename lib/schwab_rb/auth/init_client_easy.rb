require 'oauth2'
require_relative 'init_client_token_file'
require_relative 'init_client_login'

module SchwabRb::Auth
  def self.init_client_easy(
    api_key,
    app_secret,
    callback_url,
    token_path,
    asyncio: false,
    enforce_enums: false,
    callback_timeout: 300.0,
    interactive: true,
    requested_browser: nil)

    begin
      if File.exist?(token_path)
        client = SchwabRb::Auth::init_client_token_file(
          api_key,
          app_secret,
          token_path,
          enforce_enums: enforce_enums
        )
        client.refresh! if client.session.expired?
        raise OAuth2::Error.new("Token expired") if client.session.expired?
        client
      else
        raise OAuth2::Error.new("No token found")
      end
    rescue
      SchwabRb::Auth::init_client_login(
        api_key,
        app_secret,
        callback_url,
        token_path,
        asyncio: asyncio,
        enforce_enums: enforce_enums,
        callback_timeout: callback_timeout,
        interactive: interactive,
        requested_browser: requested_browser
      )
    end
  end
end
