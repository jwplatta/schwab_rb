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

    it "saves and loads a token" do
      database.save_token("my_api_key", token_data)
      result = database.load_token("my_api_key")

      expect(result["timestamp"]).to eq(1_700_000_000)
      expect(result["token"]["access_token"]).to eq("access_123")
      expect(result["token"]["refresh_token"]).to eq("refresh_456")
      expect(result["token"]["expires_at"]).to eq(1_700_001_800)
      expect(result["token"]["expires_in"]).to eq(1800)
      expect(result["token"]["token_type"]).to eq("Bearer")
      expect(result["token"]["scope"]).to eq("api")
      expect(result["token"]["id_token"]).to eq("id_789")
    end

    it "returns nil for unknown api_key" do
      expect(database.load_token("nonexistent")).to be_nil
    end

    it "upserts on duplicate api_key" do
      database.save_token("my_api_key", token_data)

      updated_data = token_data.dup
      updated_data["token"] = token_data["token"].merge("access_token" => "new_access")
      updated_data["timestamp"] = 1_700_002_000

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
          expires_at: 1_700_001_800,
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
    let(:accounts) do
      [
        { account_number: "12345", account_hash: "hash_a", nickname: "Trading",
          account_type: "BROKERAGE", primary_account: true },
        { account_number: "67890", account_hash: "hash_b", nickname: "IRA",
          account_type: "IRA", primary_account: false }
      ]
    end

    it "saves and loads accounts" do
      database.save_accounts(accounts)
      result = database.load_accounts

      expect(result.length).to eq(2)
      expect(result[0][:account_number]).to eq("12345")
      expect(result[0][:account_hash]).to eq("hash_a")
      expect(result[0][:nickname]).to eq("Trading")
      expect(result[0][:primary_account]).to be true
      expect(result[1][:account_number]).to eq("67890")
      expect(result[1][:primary_account]).to be false
    end

    it "loads a single account hash by number" do
      database.save_accounts(accounts)

      expect(database.load_account_hash("12345")).to eq("hash_a")
      expect(database.load_account_hash("67890")).to eq("hash_b")
      expect(database.load_account_hash("99999")).to be_nil
    end

    it "upserts accounts on duplicate account_number" do
      database.save_accounts(accounts)
      database.save_accounts([{ account_number: "12345", account_hash: "new_hash",
                                nickname: "Updated", account_type: "BROKERAGE",
                                primary_account: true }])

      result = database.load_account_hash("12345")
      expect(result).to eq("new_hash")
    end

    it "returns empty array when no accounts exist" do
      expect(database.load_accounts).to eq([])
    end
  end
end
