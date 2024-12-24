require "spec_helper"

describe SchwabRb::Auth do
  describe ".build_auth_context" do
    it do
      SchwabRb::Auth.build_auth_context(
        "api_key", "https://127.0.0.1:8182", state: nil
      )
    end
  end

  describe ".from_login_flow" do
    xit do
      expect do
        client = SchwabRb::Auth.init_client_login(
          ENV["SCHWAB_API_KEY"],
          ENV["SCHWAB_APP_SECRET"],
          ENV["APP_CALLBACK_URL"],
          ENV["TOKEN_PATH"]
        )
        puts client
      end.to_not raise_error
    end
  end
end
