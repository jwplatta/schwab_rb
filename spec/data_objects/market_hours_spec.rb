# frozen_string_literal: true

require "spec_helper"

RSpec.describe SchwabRb::DataObjects::MarketHours do
  let(:fixture_data) { JSON.parse(File.read("spec/fixtures/market_hours_equity.json")) }
  let(:market_hours) { described_class.build(fixture_data) }

  describe ".build" do
    it "creates a MarketHours instance" do
      expect(market_hours).to be_a(described_class)
    end
  end

  describe "#initialize" do
    it "initializes with market data" do
      expect(market_hours.markets).to be_a(Hash)
      expect(market_hours.markets).to have_key("equity")
    end
  end

  describe "#to_h" do
    it "returns hash representation" do
      result = market_hours.to_h
      expect(result).to be_a(Hash)
      expect(result).to have_key("equity")
    end
  end

  describe "#equity" do
    it "returns equity market data" do
      equity = market_hours.equity
      expect(equity).to be_a(Hash)
      expect(equity).to have_key("equity")
    end
  end

  describe "#find_market_info" do
    it "finds market info by type and key" do
      info = market_hours.find_market_info("equity", "equity")
      expect(info).to be_a(SchwabRb::DataObjects::MarketHours::MarketInfo)
    end
  end

  describe SchwabRb::DataObjects::MarketHours::MarketInfo do
    let(:equity_data) { fixture_data["equity"]["equity"] }
    let(:market_info) { described_class.new(equity_data) }

    describe "#initialize" do
      it "initializes with market info data" do
        expect(market_info.market_type).to eq("EQUITY")
        expect(market_info.product).to eq("equity")
      end
    end

    describe "#to_h" do
      it "returns hash representation" do
        result = market_info.to_h
        expect(result).to be_a(Hash)
        expect(result).to have_key("marketType")
      end
    end

    describe "#open?" do
      it "returns boolean for market status" do
        expect([true, false]).to include(market_info.open?)
      end
    end
  end
end
