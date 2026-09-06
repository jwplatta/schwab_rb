# frozen_string_literal: true

require "spec_helper"

describe SchwabRb::Auth::TokenManager do
  let(:token) do
    SchwabRb::Auth::Token.new(
      token: "access_token",
      expires_in: 3600,
      token_type: "Bearer",
      scope: "openid",
      refresh_token: "refresh_token",
      id_token: "id_token",
      expires_at: 4_102_444_800
    )
  end

  let(:database) { SchwabRb::Storage::Database.new(":memory:") }

  after { database.close }

  it "does not raise error when subject is initialized" do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end

  describe ".from_database" do
    it "returns nil when no token exists for the api_key" do
      result = described_class.from_database("unknown_key", database: database)
      expect(result).to be_nil
    end

    it "loads a token from the database" do
      manager = described_class.new(token, Time.now.to_i, api_key: "test_key", database: database)
      manager.save

      loaded = described_class.from_database("test_key", database: database)

      expect(loaded).to be_a(described_class)
      expect(loaded.token.token).to eq("access_token")
      expect(loaded.token.refresh_token).to eq("refresh_token")
      expect(loaded.token.expires_at).to eq(4_102_444_800)
      expect(loaded.api_key).to eq("test_key")
    end
  end

  describe "#save" do
    it "persists token data to the database" do
      manager = described_class.new(token, 1_700_000_000, api_key: "save_key", database: database)
      manager.save

      data = database.load_token("save_key")
      expect(data["token"]["access_token"]).to eq("access_token")
      expect(data["token"]["refresh_token"]).to eq("refresh_token")
      expect(data["timestamp"]).to eq(1_700_000_000)
    end
  end

  describe "#to_h" do
    it "returns a hash representation of the token" do
      manager = described_class.new(token, 1_700_000_000, api_key: "test_key")
      result = manager.to_h

      expect(result[:timestamp]).to eq(1_700_000_000)
      expect(result[:token][:access_token]).to eq("access_token")
      expect(result[:token][:refresh_token]).to eq("refresh_token")
      expect(result[:token][:token_type]).to eq("Bearer")
    end
  end
end
