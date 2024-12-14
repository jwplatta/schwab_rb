require_relative 'base_client'

module SchwabRb
  class Client < BaseClient
    attr_reader :api_key, :session, :token_metadata, :enforce_enums

    def initialize(api_key, session, token_metadata:, enforce_enums: true)
      @api_key = api_key
      @session = session
      @token_metadata = token_metadata
      @enforce_enums = enforce_enums
    end

    private

    def get(path, params)
    end

    def post(path, data)
    end

    def put(path, data)
    end

    def delete(path)
    end
  end
end
