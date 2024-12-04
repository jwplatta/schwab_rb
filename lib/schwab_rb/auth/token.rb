module SchwabRb::Auth
  class Token
    def initialize(
      token: nil,
      expires_in: nil,
      token_type: "Bearer",
      scope: nil,
      refresh_token: nil,
      id_token: nil,
      expires_at: nil
    )
      @token = token
      @expires_in = expires_in
      @token_type = token_type
      @scope = scope
      @refresh_token = refresh_token
      @id_token = id_token
      @expires_at = expires_at
    end

    attr_reader :token, :expires_in, :token_type, :scope,
      :refresh_token, :id_token, :expires_at
  end
end
