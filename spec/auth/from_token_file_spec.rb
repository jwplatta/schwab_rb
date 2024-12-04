require "spec_helper"

describe SchwabRb::Auth do
  describe '.from_token_file' do
    it do
      expect do
        client = SchwabRb::Auth.from_token_file(
          ENV["SCHWAB_API_KEY"],
          ENV["SCHWAB_APP_SECRET"],
          ENV["TOKEN_PATH"],
        )
      end.to_not raise_error
    end
  end
end
