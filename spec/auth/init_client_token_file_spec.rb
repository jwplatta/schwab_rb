require "spec_helper"

describe SchwabRb::Auth do
  describe ".from_token_file" do
    it "initializes client from token file" do
      token_path = File.join(__dir__, "../fixtures/token.json")
      
      expect do
        SchwabRb::Auth.init_client_token_file(
          "fake_api_key",
          "fake_app_secret",
          token_path
        )
      end.to_not raise_error
    end
  end
end
