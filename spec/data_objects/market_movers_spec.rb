# frozen_string_literal: true

require "rspec"
require "schwab_rb"

RSpec.describe SchwabRb::DataObjects::MarketMoversFactory do
  let(:movers_data) do
    JSON.parse(
      File.read(
        "spec/fixtures/movers_volume.json"
      ),
      symbolize_names: true
    )
  end

  describe ".build" do
    it "creates a MarketMovers object from movers data" do
      market_movers = SchwabRb::DataObjects::MarketMoversFactory.build(movers_data)
      expect(market_movers).to be_an_instance_of(SchwabRb::DataObjects::MarketMovers)
      expect(market_movers.count).to eq(10)
      expect(market_movers.movers.first).to be_an_instance_of(SchwabRb::DataObjects::Mover)
    end

    it "handles empty screeners data" do
      empty_data = { screeners: [] }
      market_movers = SchwabRb::DataObjects::MarketMoversFactory.build(empty_data)
      expect(market_movers.count).to eq(0)
      expect(market_movers.movers).to be_empty
    end

    it "handles missing screeners key" do
      empty_data = {}
      market_movers = SchwabRb::DataObjects::MarketMoversFactory.build(empty_data)
      expect(market_movers.count).to eq(0)
      expect(market_movers.movers).to be_empty
    end
  end
end

RSpec.describe SchwabRb::DataObjects::MarketMovers do
  let(:movers_data) do
    JSON.parse(
      File.read(
        "spec/fixtures/movers_volume.json"
      ),
      symbolize_names: true
    )
  end

  let(:market_movers) do
    SchwabRb::DataObjects::MarketMoversFactory.build(movers_data)
  end

  describe "#count" do
    it "returns the number of movers" do
      expect(market_movers.count).to eq(10)
    end
  end

  describe "#symbols" do
    it "returns all symbols as an array" do
      symbols = market_movers.symbols
      expect(symbols).to include("NVDA", "TSLA", "F", "WBD", "INTC", "AAPL", "PLTR", "VZ", "AMD", "GOOGL")
      expect(symbols.size).to eq(10)
    end
  end

  describe "#find_by_symbol" do
    it "finds a mover by symbol" do
      nvda_mover = market_movers.find_by_symbol("NVDA")
      expect(nvda_mover).not_to be_nil
      expect(nvda_mover.symbol).to eq("NVDA")
      expect(nvda_mover.description).to eq("NVIDIA CORP")
    end

    it "returns nil for non-existent symbol" do
      non_existent = market_movers.find_by_symbol("NONEXISTENT")
      expect(non_existent).to be_nil
    end
  end

  describe "#top" do
    it "returns the top 5 movers by default" do
      top_movers = market_movers.top
      expect(top_movers.size).to eq(5)
      expect(top_movers.first.symbol).to eq("NVDA")
    end

    it "returns the specified number of top movers" do
      top_3 = market_movers.top(3)
      expect(top_3.size).to eq(3)
      expect(top_3.map(&:symbol)).to eq(%w[NVDA TSLA F])
    end
  end

  describe "#each" do
    it "iterates over all movers" do
      symbols = []
      market_movers.each { |mover| symbols << mover.symbol }
      expect(symbols.size).to eq(10)
      expect(symbols.first).to eq("NVDA")
    end
  end

  describe "#to_a" do
    it "returns the movers array" do
      movers_array = market_movers.to_a
      expect(movers_array).to eq(market_movers.movers)
      expect(movers_array.size).to eq(10)
    end
  end
end

RSpec.describe SchwabRb::DataObjects::Mover do
  let(:mover_data) do
    {
      description: "NVIDIA CORP",
      volume: 83_043_184,
      lastPrice: 172.56,
      netChange: 0.15,
      marketShare: 5.18,
      totalVolume: 1_604_124_927,
      trades: 918_661,
      netPercentChange: 0.0008,
      symbol: "NVDA"
    }
  end

  let(:mover) { SchwabRb::DataObjects::Mover.new(mover_data) }

  describe "initialization" do
    it "creates a mover with correct attributes" do
      expect(mover.symbol).to eq("NVDA")
      expect(mover.description).to eq("NVIDIA CORP")
      expect(mover.volume).to eq(83_043_184)
      expect(mover.last_price).to eq(172.56)
      expect(mover.net_change).to eq(0.15)
      expect(mover.market_share).to eq(5.18)
      expect(mover.total_volume).to eq(1_604_124_927)
      expect(mover.trades).to eq(918_661)
      expect(mover.net_percent_change).to eq(0.0008)
    end
  end

  describe "#percentage_of_total_volume" do
    it "calculates the correct percentage of total volume" do
      percentage = mover.percentage_of_total_volume
      expected = (83_043_184.0 / 1_604_124_927.0) * 100.0
      expect(percentage).to be_within(0.01).of(expected)
    end

    it "returns 0 when total_volume is zero" do
      zero_volume_data = mover_data.merge(totalVolume: 0)
      zero_mover = SchwabRb::DataObjects::Mover.new(zero_volume_data)
      expect(zero_mover.percentage_of_total_volume).to eq(0.0)
    end

    it "returns 0 when total_volume is nil" do
      nil_volume_data = mover_data.merge(totalVolume: nil)
      nil_mover = SchwabRb::DataObjects::Mover.new(nil_volume_data)
      expect(nil_mover.percentage_of_total_volume).to eq(0.0)
    end
  end

  describe "#positive_change?" do
    it "returns true for positive net change" do
      expect(mover.positive_change?).to be true
    end

    it "returns false for negative net change" do
      negative_data = mover_data.merge(netChange: -0.15)
      negative_mover = SchwabRb::DataObjects::Mover.new(negative_data)
      expect(negative_mover.positive_change?).to be false
    end

    it "returns false for zero net change" do
      zero_data = mover_data.merge(netChange: 0)
      zero_mover = SchwabRb::DataObjects::Mover.new(zero_data)
      expect(zero_mover.positive_change?).to be false
    end
  end

  describe "#negative_change?" do
    it "returns false for positive net change" do
      expect(mover.negative_change?).to be false
    end

    it "returns true for negative net change" do
      negative_data = mover_data.merge(netChange: -0.15)
      negative_mover = SchwabRb::DataObjects::Mover.new(negative_data)
      expect(negative_mover.negative_change?).to be true
    end

    it "returns false for zero net change" do
      zero_data = mover_data.merge(netChange: 0)
      zero_mover = SchwabRb::DataObjects::Mover.new(zero_data)
      expect(zero_mover.negative_change?).to be false
    end
  end

  describe "#net_change_percentage" do
    it "converts decimal to percentage and rounds to 2 places" do
      expect(mover.net_change_percentage).to eq(0.08)
    end

    it "handles negative percentages" do
      negative_data = mover_data.merge(netPercentChange: -0.0256)
      negative_mover = SchwabRb::DataObjects::Mover.new(negative_data)
      expect(negative_mover.net_change_percentage).to eq(-2.56)
    end

    it "returns nil when net_percent_change is nil" do
      nil_data = mover_data.merge(netPercentChange: nil)
      nil_mover = SchwabRb::DataObjects::Mover.new(nil_data)
      expect(nil_mover.net_change_percentage).to be_nil
    end
  end

  describe "#to_h" do
    it "returns a hash representation of the mover" do
      hash = mover.to_h
      expect(hash[:symbol]).to eq("NVDA")
      expect(hash[:description]).to eq("NVIDIA CORP")
      expect(hash[:volume]).to eq(83_043_184)
      expect(hash[:last_price]).to eq(172.56)
      expect(hash[:net_change]).to eq(0.15)
      expect(hash[:market_share]).to eq(5.18)
      expect(hash[:total_volume]).to eq(1_604_124_927)
      expect(hash[:trades]).to eq(918_661)
      expect(hash[:net_percent_change]).to eq(0.0008)
    end
  end

  describe "#to_s" do
    it "returns a string representation of the mover" do
      string_rep = mover.to_s
      expect(string_rep).to include("NVDA")
      expect(string_rep).to include("83043184")
      expect(string_rep).to include("172.56")
      expect(string_rep).to include("0.15")
    end
  end
end
