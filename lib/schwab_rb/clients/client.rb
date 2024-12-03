module SchwabRb
  class Client
    attr_reader :api_key, :session, :token_metadata, :enforce_enums

    def initialize(api_key, session, token_metadata:, enforce_enums: true)
      @api_key = api_key
      @session = session
      @token_metadata = token_metadata
      @enforce_enums = enforce_enums
    end
  end
end
