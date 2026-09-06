# frozen_string_literal: true

require "oauth2"
require_relative "init_client_from_database"
require_relative "init_client_login"
require_relative "../path_support"

module SchwabRb
  module Auth
    def self.init_client_easy(
      api_key,
      app_secret,
      callback_url,
      token_path = nil,
      asyncio: false,
      enforce_enums: false,
      callback_timeout: 300.0,
      interactive: true,
      requested_browser: nil,
      database: nil
    )
      client = SchwabRb::Auth.init_client_from_database(
        api_key,
        app_secret,
        enforce_enums: enforce_enums,
        database: database
      )

      if client
        client.refresh! if client.session.expired?
        raise OAuth2::Error, "Token expired" if client.session.expired?
        return client
      end

      SchwabRb::Auth.init_client_login(
        api_key,
        app_secret,
        callback_url,
        token_path,
        asyncio: asyncio,
        enforce_enums: enforce_enums,
        callback_timeout: callback_timeout,
        interactive: interactive,
        requested_browser: requested_browser,
        database: database
      )
    rescue StandardError
      SchwabRb::Auth.init_client_login(
        api_key,
        app_secret,
        callback_url,
        token_path,
        asyncio: asyncio,
        enforce_enums: enforce_enums,
        callback_timeout: callback_timeout,
        interactive: interactive,
        requested_browser: requested_browser,
        database: database
      )
    end
  end
end
