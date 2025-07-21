require "oauth2"

module SchwabRb::Auth
  class AuthContext
    class << self
      def build(oauth_client, callback_url, authorization_url, state: nil)
        auth_params = { redirect_uri: callback_url }
        auth_params[:state] = state if state
        authorization_url = oauth_client.auth_code.authorize_url(auth_params)

        new(callback_url, authorization_url, state)
      end
    end

    def initialize(callback_url, authorization_url, state)
      @callback_url = callback_url
      @authorization_url = authorization_url
      @state = state
    end

    attr_reader :callback_url, :authorization_url, :state
  end
end
