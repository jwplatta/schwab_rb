require "spec_helper"

describe SchwabRb::Client do
  it "does not raise" do
    expect { described_class.new(nil, nil, token_metadata: nil) }.not_to raise_error
  end
end
describe "#token_age" do
  let(:api_key) { "test_api_key" }
  let(:session) { double("session") }
  # let(:token_metadata) { { "created_at" => Time.now - 3600 } }
  let(:client) do
    api_key = ENV["SCHWAB_API_KEY"]
    app_secret = ENV["SCHWAB_APP_SECRET"]
    token_path = ENV["TOKEN_PATH"]
    SchwabRb::Auth.from_token_file(api_key, app_secret, token_path)
  end

  it "returns the age of the token in seconds" do
    expect(client.token_age).to be_within(1).of(3600)
  end

  context "when token_metadata is nil" do
    let(:token_metadata) { nil }

    it "returns nil" do
      expect(client.token_age).to be_nil
    end
  end

  context "when token_manager does not have 'created_at'" do
    let(:token_metadata) { {} }

    it "returns nil" do
      expect(client.token_age).to be_nil
    end
  end

  describe "accounts" do
    fit "returns an array of accounts" do
      resp = client.get_accounts
      binding.pry
    end
  end
end