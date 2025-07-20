# frozen_string_literal: true

require 'rspec'
require 'schwab_rb'

RSpec.describe SchwabRb::DataObjects::QuoteFactory do
  let(:option_quote_data) do
    JSON.parse(
      File.read(
        'spec/fixtures/quotes/NVDA  250307P00095000_quote.json'
      ),
      symbolize_names: true
    )
  end

  let(:equity_quote_data) do
    JSON.parse(
      File.read(
        'spec/fixtures/quotes/NVDA_quote.json'
      ),
      symbolize_names: true
    )
  end

  let(:index_quote_data) do
    JSON.parse(
      File.read(
        'spec/fixtures/quotes/$SPX_quote.json'
      ),
      symbolize_names: true
    )
  end

  describe '.build' do
    it 'creates an OptionQuote for option data' do
      quote = SchwabRb::DataObjects::QuoteFactory.build(option_quote_data)
      expect(quote).to be_an_instance_of(SchwabRb::DataObjects::OptionQuote)
      expect(quote.symbol).to eq('NVDA  250307P00095000')
      expect(quote.asset_main_type).to eq('OPTION')
    end

    it 'creates an EquityQuote for equity data' do
      quote = SchwabRb::DataObjects::QuoteFactory.build(equity_quote_data)
      expect(quote).to be_an_instance_of(SchwabRb::DataObjects::EquityQuote)
      expect(quote.symbol).to eq('NVDA')
      expect(quote.asset_main_type).to eq('EQUITY')
    end

    it 'creates an IndexQuote for index data' do
      quote = SchwabRb::DataObjects::QuoteFactory.build(index_quote_data)
      expect(quote).to be_an_instance_of(SchwabRb::DataObjects::IndexQuote)
      expect(quote.symbol).to eq('$SPX')
      expect(quote.asset_main_type).to eq('INDEX')
    end
  end
end

RSpec.describe SchwabRb::DataObjects::OptionQuote do
  let(:raw_data) do
    JSON.parse(
      File.read(
        'spec/fixtures/quotes/NVDA  250307P00095000_quote.json'
      ),
      symbolize_names: true
    )
  end

  describe 'initialization' do
    it 'creates an option quote with correct attributes' do
      quote = SchwabRb::DataObjects::QuoteFactory.build(raw_data)

      expect(quote.symbol).to eq('NVDA  250307P00095000')
      expect(quote.asset_main_type).to eq('OPTION')
      expect(quote.ask_price).to eq(2.13)
      expect(quote.bid_price).to eq(1.41)
      expect(quote.last_price).to eq(1.62)
      expect(quote.mark).to eq(1.77)
      expect(quote.delta).to eq(-0.10887034)
      expect(quote.gamma).to eq(0.00614904)
      expect(quote.theta).to eq(-0.07988814)
      expect(quote.vega).to eq(0.07311685)
      expect(quote.contract_type).to eq('P')
      expect(quote.days_to_expiration).to eq(36)
      expect(quote.strike_price).to eq(95.0)
    end
  end
end

RSpec.describe SchwabRb::DataObjects::EquityQuote do
  let(:raw_data) do
    JSON.parse(
      File.read(
        'spec/fixtures/quotes/NVDA_quote.json'
      ),
      symbolize_names: true
    )
  end

  describe 'initialization' do
    it 'creates an equity quote with correct attributes' do
      quote = SchwabRb::DataObjects::QuoteFactory.build(raw_data)

      expect(quote.symbol).to eq('NVDA')
      expect(quote.asset_main_type).to eq('EQUITY')
      expect(quote.ask_price).to eq(123.22)
      expect(quote.bid_price).to eq(123.2)
      expect(quote.last_price).to eq(123.2291)
      expect(quote.mark).to eq(123.22)
      expect(quote.net_change).to eq(-0.4709)
      expect(quote.net_percent_change).to eq(-0.38067906)
      expect(quote.total_volume).to eq(392925469)
    end
  end
end

RSpec.describe SchwabRb::DataObjects::IndexQuote do
  let(:raw_data) do
    JSON.parse(
      File.read(
        'spec/fixtures/quotes/$SPX_quote.json'
      ),
      symbolize_names: true
    )
  end

  describe 'initialization' do
    it 'creates an index quote with correct attributes' do
      quote = SchwabRb::DataObjects::QuoteFactory.build(raw_data)

      expect(quote.symbol).to eq('$SPX')
      expect(quote.asset_main_type).to eq('INDEX')
      expect(quote.last_price).to eq(6071.17)
      expect(quote.net_change).to eq(31.86)
      expect(quote.net_percent_change).to eq(0.52754371)
      expect(quote.high_price).to eq(6086.64)
      expect(quote.low_price).to eq(6027.46)
    end
  end
end
