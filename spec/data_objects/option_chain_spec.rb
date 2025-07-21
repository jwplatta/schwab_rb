# frozen_string_literal: true

require "rspec"
require "schwab_rb"

RSpec.describe SchwabRb::DataObjects::OptionChain do
  let(:raw_data) do
    JSON.parse(File.read("spec/fixtures/option_chains/AAPL.json"), symbolize_names: true)
  end

  describe ".build" do
    it "creates an option chain object from raw data" do
      option_chain = SchwabRb::DataObjects::OptionChain.build(raw_data)
      expect(option_chain).to be_an_instance_of SchwabRb::DataObjects::OptionChain
      expect(option_chain.symbol).to eq "AAPL"
      expect(option_chain.status).to eq "SUCCESS"
      expect(option_chain.underlying_price).to eq 228.375
      expect(option_chain.volatility).to eq 29.0
      expect(option_chain.days_to_expiration).to eq 0.0

      # Test call options
      expect(option_chain.call_opts.size).to be >= 0
      option_chain.call_opts.each do |option|
        expect(option).to be_an_instance_of SchwabRb::DataObjects::Option
      end

      # Test put options
      expect(option_chain.put_opts.size).to be > 0
      option_chain.put_opts.each do |option|
        expect(option).to be_an_instance_of SchwabRb::DataObjects::Option
      end
    end
  end
end
