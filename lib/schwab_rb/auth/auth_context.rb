module SchwabRb::Auth
  AuthContext = Struct.new(
    :api_key, :callback_url, :authorization_url, :state
  )
end
