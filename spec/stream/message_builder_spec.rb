# frozen_string_literal: true

require "spec_helper"
require "schwab_rb/stream/services"
require "schwab_rb/stream/fields"
require "schwab_rb/stream/message_builder"

RSpec.describe SchwabRb::Stream::MessageBuilder do
  subject(:builder) { described_class.new("customer123", "correl456") }

  describe "#build_login" do
    it "builds a login request with correct structure" do
      result = builder.build_login("test_token", "channel1", "func1")

      expect(result["service"]).to eq("ADMIN")
      expect(result["command"]).to eq("LOGIN")
      expect(result["requestid"]).to eq(1)
      expect(result["SchwabClientCustomerId"]).to eq("customer123")
      expect(result["SchwabClientCorrelId"]).to eq("correl456")
      expect(result["parameters"]["Authorization"]).to eq("Bearer test_token")
      expect(result["parameters"]["SchwabClientChannel"]).to eq("channel1")
      expect(result["parameters"]["SchwabClientFunctionId"]).to eq("func1")
    end
  end

  describe "#build_logout" do
    it "builds a logout request" do
      result = builder.build_logout

      expect(result["service"]).to eq("ADMIN")
      expect(result["command"]).to eq("LOGOUT")
      expect(result["SchwabClientCustomerId"]).to eq("customer123")
      expect(result["SchwabClientCorrelId"]).to eq("correl456")
    end
  end

  describe "#build_request" do
    it "builds a subscription request with keys and fields" do
      result = builder.build_request(
        "LEVELONE_EQUITIES", "SUBS",
        keys: ["AAPL", "MSFT"],
        fields: [0, 1, 2, 3]
      )

      expect(result["service"]).to eq("LEVELONE_EQUITIES")
      expect(result["command"]).to eq("SUBS")
      expect(result["parameters"]["keys"]).to eq("AAPL,MSFT")
      expect(result["parameters"]["fields"]).to eq("0,1,2,3")
    end

    it "resolves :all fields for a service" do
      result = builder.build_request(
        "NYSE_BOOK", "ADD",
        keys: ["AAPL"],
        fields: :all
      )

      expect(result["parameters"]["fields"]).to eq("0,1,2,3")
    end

    it "accepts Field constants" do
      result = builder.build_request(
        "LEVELONE_EQUITIES", "SUBS",
        keys: ["AAPL"],
        fields: [
          SchwabRb::Stream::Fields::LevelOneEquity::BID_PRICE,
          SchwabRb::Stream::Fields::LevelOneEquity::ASK_PRICE
        ]
      )

      expect(result["parameters"]["fields"]).to eq("1,2")
    end

    it "auto-increments request IDs" do
      r1 = builder.build_login("token", "ch", "fn")
      r2 = builder.build_request("NYSE_BOOK", "SUBS", keys: ["AAPL"], fields: :all)
      r3 = builder.build_logout

      expect(r1["requestid"]).to eq(1)
      expect(r2["requestid"]).to eq(2)
      expect(r3["requestid"]).to eq(3)
    end
  end

  describe "#wrap_requests" do
    it "wraps requests in the expected JSON format" do
      request = builder.build_request("NYSE_BOOK", "SUBS", keys: ["AAPL"], fields: :all)
      json = builder.wrap_requests(request)
      parsed = JSON.parse(json)

      expect(parsed).to have_key("requests")
      expect(parsed["requests"]).to be_an(Array)
      expect(parsed["requests"].length).to eq(1)
      expect(parsed["requests"][0]["service"]).to eq("NYSE_BOOK")
    end

    it "wraps multiple requests" do
      r1 = builder.build_request("NYSE_BOOK", "SUBS", keys: ["AAPL"], fields: :all)
      r2 = builder.build_request("NASDAQ_BOOK", "SUBS", keys: ["AMD"], fields: :all)
      json = builder.wrap_requests(r1, r2)
      parsed = JSON.parse(json)

      expect(parsed["requests"].length).to eq(2)
    end
  end
end
