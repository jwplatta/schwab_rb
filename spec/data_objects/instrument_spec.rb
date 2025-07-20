# frozen_string_literal: true

require 'rspec'
require 'schwab_rb'
require 'json'

RSpec.describe SchwabRb::DataObjects::Instrument do
  let(:option_instrument_data) do
    JSON.parse(File.read('spec/fixtures/instrument.json'), symbolize_names: true)
  end

  let(:equity_instrument_data) do
    JSON.parse(File.read('spec/fixtures/equity_instrument.json'), symbolize_names: true)
  end

  describe '.build' do
    it 'creates an instrument object from option data' do
      instrument = SchwabRb::DataObjects::Instrument.build(option_instrument_data)

      expect(instrument).to be_an_instance_of(SchwabRb::DataObjects::Instrument)
      expect(instrument.symbol).to eq('TSLA  250221P00340000')
      expect(instrument.description).to eq('TESLA INC 02/21/2025 $340 Put')
      expect(instrument.asset_type).to eq('OPTION')
      expect(instrument.put_call).to eq('PUT')
      expect(instrument.underlying_symbol).to eq('TSLA')
    end

    it 'creates an instrument object from equity data' do
      instrument = SchwabRb::DataObjects::Instrument.build(equity_instrument_data)

      expect(instrument).to be_an_instance_of(SchwabRb::DataObjects::Instrument)
      expect(instrument.symbol).to eq('TSLA')
      expect(instrument.description).to eq('TESLA INC')
      expect(instrument.asset_type).to eq('EQUITY')
      expect(instrument.put_call).to be_nil
      expect(instrument.underlying_symbol).to be_nil
    end
  end

  describe '#option?' do
    it 'returns true for option instruments' do
      instrument = SchwabRb::DataObjects::Instrument.build(option_instrument_data)
      expect(instrument.option?).to be true
    end

    it 'returns false for equity instruments' do
      instrument = SchwabRb::DataObjects::Instrument.build(equity_instrument_data)
      expect(instrument.option?).to be false
    end
  end
end

RSpec.describe SchwabRb::DataObjects::OptionDeliverable do
  let(:option_deliverable_data) do
    {
      symbol: 'TSLA',
      deliverableUnits: 100.0,
      deliverableNumber: 1,
      strikePercent: 1.0,
      rootSymbol: 'TSLA'
    }
  end

  describe '.build' do
    it 'creates an option deliverable object from raw data' do
      deliverable = SchwabRb::DataObjects::OptionDeliverable.build(option_deliverable_data)

      expect(deliverable).to be_an_instance_of(SchwabRb::DataObjects::OptionDeliverable)
      expect(deliverable.symbol).to eq('TSLA')
      expect(deliverable.deliverable_units).to eq(100.0)
      expect(deliverable.deliverable_number).to eq(1)
      expect(deliverable.strike_percent).to eq(1.0)
      expect(deliverable.root_symbol).to eq('TSLA')
      expect(deliverable.deliverable).to be_nil
    end
  end

  describe '#to_h' do
    it 'converts the option deliverable object back to a hash with the same structure as the input data' do
      deliverable = SchwabRb::DataObjects::OptionDeliverable.build(option_deliverable_data)
      deliverable_hash = deliverable.to_h

      expect(deliverable_hash[:symbol]).to eq(option_deliverable_data[:symbol])
      expect(deliverable_hash[:deliverableUnits]).to eq(option_deliverable_data[:deliverableUnits])
      expect(deliverable_hash[:deliverableNumber]).to eq(option_deliverable_data[:deliverableNumber])
      expect(deliverable_hash[:strikePercent]).to eq(option_deliverable_data[:strikePercent])
      expect(deliverable_hash[:rootSymbol]).to eq(option_deliverable_data[:rootSymbol])
      expect(deliverable_hash[:deliverable]).to be_nil
    end
  end
end

RSpec.describe SchwabRb::DataObjects::Asset do
  let(:asset_data) do
    {
      assetType: 'FUTURE',
      status: 'ACTIVE',
      symbol: 'ESZ3',
      instrumentId: 12_345_678,
      closingPrice: 4350.25,
      type: 'FUTURE',
      description: 'E-mini S&P 500 Future December 2023',
      activeContract: true,
      expirationDate: '2023-12-15',
      lastTradingDate: '2023-12-14',
      multiplier: 50.0,
      futureType: 'EMINI'
    }
  end

  describe '.build' do
    it 'creates an asset object from raw data' do
      asset = SchwabRb::DataObjects::Asset.build(asset_data)

      expect(asset).to be_an_instance_of(SchwabRb::DataObjects::Asset)
      expect(asset.asset_type).to eq('FUTURE')
      expect(asset.status).to eq('ACTIVE')
      expect(asset.symbol).to eq('ESZ3')
      expect(asset.instrument_id).to eq(12_345_678)
      expect(asset.closing_price).to eq(4350.25)
      expect(asset.type).to eq('FUTURE')
      expect(asset.description).to eq('E-mini S&P 500 Future December 2023')
      expect(asset.active_contract).to be true
      expect(asset.expiration_date).to eq('2023-12-15')
      expect(asset.last_trading_date).to eq('2023-12-14')
      expect(asset.multiplier).to eq(50.0)
      expect(asset.future_type).to eq('EMINI')
    end
  end

  describe '#to_h' do
    it 'converts the asset object back to a hash with the same structure as the input data' do
      asset = SchwabRb::DataObjects::Asset.build(asset_data)
      asset_hash = asset.to_h

      expect(asset_hash[:assetType]).to eq(asset_data[:assetType])
      expect(asset_hash[:status]).to eq(asset_data[:status])
      expect(asset_hash[:symbol]).to eq(asset_data[:symbol])
      expect(asset_hash[:instrumentId]).to eq(asset_data[:instrumentId])
      expect(asset_hash[:closingPrice]).to eq(asset_data[:closingPrice])
      expect(asset_hash[:type]).to eq(asset_data[:type])
      expect(asset_hash[:description]).to eq(asset_data[:description])
      expect(asset_hash[:activeContract]).to eq(asset_data[:activeContract])
      expect(asset_hash[:expirationDate]).to eq(asset_data[:expirationDate])
      expect(asset_hash[:lastTradingDate]).to eq(asset_data[:lastTradingDate])
      expect(asset_hash[:multiplier]).to eq(asset_data[:multiplier])
      expect(asset_hash[:futureType]).to eq(asset_data[:futureType])
    end
  end
end
