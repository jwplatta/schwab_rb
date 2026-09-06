# frozen_string_literal: true

require "spec_helper"
require "schwab_rb/storage/database"

RSpec.describe SchwabRb::Storage::Database do
  subject(:database) { described_class.new(":memory:") }

  after { database.close }

  describe "token operations" do
    let(:token_data) do
      {
        "timestamp" => 1_700_000_000,
        "token" => {
          "access_token" => "access_123",
          "refresh_token" => "refresh_456",
          "expires_at" => 1_700_001_800,
          "expires_in" => 1800,
          "token_type" => "Bearer",
          "scope" => "api",
          "id_token" => "id_789"
        }
      }
    end

    it "saves and loads a valid token" do
      valid_data = token_data.merge(
        "token" => token_data["token"].merge("expires_at" => Time.now.to_i + 1800)
      )
      database.save_token("my_api_key", valid_data)
      result = database.load_token("my_api_key")

      expect(result["timestamp"]).to eq(1_700_000_000)
      expect(result["token"]["access_token"]).to eq("access_123")
      expect(result["token"]["refresh_token"]).to eq("refresh_456")
      expect(result["token"]["expires_in"]).to eq(1800)
      expect(result["token"]["token_type"]).to eq("Bearer")
      expect(result["token"]["scope"]).to eq("api")
      expect(result["token"]["id_token"]).to eq("id_789")
    end

    it "returns nil and removes the record for an expired token" do
      expired_data = token_data.merge(
        "token" => token_data["token"].merge("expires_at" => Time.now.to_i - 60)
      )
      database.save_token("my_api_key", expired_data)

      expect(database.load_token("my_api_key")).to be_nil

      # row should be gone
      database.save_token("my_api_key", token_data.merge(
        "token" => token_data["token"].merge("expires_at" => Time.now.to_i + 1800)
      ))
      expect(database.load_token("my_api_key")).not_to be_nil
    end

    it "returns nil for unknown api_key" do
      expect(database.load_token("nonexistent")).to be_nil
    end

    it "replaces the existing token on save" do
      valid_data = token_data.merge(
        "token" => token_data["token"].merge("expires_at" => Time.now.to_i + 1800)
      )
      database.save_token("my_api_key", valid_data)

      updated_data = valid_data.merge(
        "timestamp" => 1_700_002_000,
        "token" => valid_data["token"].merge("access_token" => "new_access")
      )
      database.save_token("my_api_key", updated_data)
      result = database.load_token("my_api_key")

      expect(result["token"]["access_token"]).to eq("new_access")
      expect(result["timestamp"]).to eq(1_700_002_000)
    end

    it "accepts symbol keys" do
      sym_data = {
        timestamp: 1_700_000_000,
        token: {
          access_token: "access_sym",
          refresh_token: "refresh_sym",
          expires_at: Time.now.to_i + 1800,
          expires_in: 1800,
          token_type: "Bearer",
          scope: "api",
          id_token: "id_sym"
        }
      }

      database.save_token("sym_key", sym_data)
      result = database.load_token("sym_key")

      expect(result["token"]["access_token"]).to eq("access_sym")
    end
  end

  describe "account operations" do
    it "saves and loads an account hash" do
      database.save_account("12345678", "HASH_ABC")
      expect(database.load_account_hash("12345678")).to eq("HASH_ABC")
    end

    it "returns nil for unknown account number" do
      expect(database.load_account_hash("99999999")).to be_nil
    end

    it "upserts on duplicate account number" do
      database.save_account("12345678", "HASH_OLD")
      database.save_account("12345678", "HASH_NEW")
      expect(database.load_account_hash("12345678")).to eq("HASH_NEW")
    end
  end
end
