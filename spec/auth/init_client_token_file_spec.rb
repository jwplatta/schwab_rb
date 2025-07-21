require "spec_helper"

describe SchwabRb::Auth do
  describe ".from_token_file" do
    it do
      expect do
        SchwabRb::Auth.init_client_token_file(
          ENV.fetch("SCHWAB_API_KEY", nil),
          ENV.fetch("SCHWAB_APP_SECRET", nil),
          ENV.fetch("TOKEN_PATH", nil)
        )
      end.to_not raise_error
    end
  end
end
