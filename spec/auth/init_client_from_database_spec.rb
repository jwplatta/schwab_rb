# frozen_string_literal: true

require "spec_helper"

describe SchwabRb::Auth do
  describe ".init_client_from_database" do
    let(:database) { SchwabRb::Storage::Database.new(":memory:") }

    after { database.close }

    it "returns nil when no token exists" do
      result = SchwabRb::Auth.init_client_from_database(
        "fake_api_key",
        "fake_app_secret",
        database: database
      )

      expect(result).to be_nil
    end

    it "returns a client when a token exists in the database" do
      token_data = {
        timestamp: Time.now.to_i,
        token: {
          access_token: "test_access",
          refresh_token: "test_refresh",
          expires_at: Time.now.to_i + 1800,
          expires_in: 1800,
          token_type: "Bearer",
          scope: "api",
          id_token: "test_id"
        }
      }
      database.save_token("fake_api_key", token_data)

      client = SchwabRb::Auth.init_client_from_database(
        "fake_api_key",
        "fake_app_secret",
        database: database
      )

      expect(client).to be_a(SchwabRb::Client)
      expect(client.api_key).to eq("fake_api_key")
    end
  end
end
