# frozen_string_literal: true

require 'spec_helper'
require 'date'

RSpec.describe SchwabRb::DataObjects::OptionExpirationChain do
  let(:fixture_data) { JSON.parse(File.read('spec/fixtures/option_expiration_chain.json')) }
  let(:expiration_chain) { described_class.build(fixture_data) }

  describe '.build' do
    it 'creates an OptionExpirationChain instance' do
      expect(expiration_chain).to be_a(described_class)
    end
  end

  describe '#initialize' do
    it 'initializes with expiration list and status' do
      expect(expiration_chain.expiration_list).to be_an(Array)
      expect(expiration_chain.status).to be_nil
    end

    it 'handles missing expiration list gracefully' do
      chain = described_class.new({})
      expect(chain.expiration_list).to eq([])
      expect(chain.status).to be_nil
    end
  end

  describe '#to_h' do
    it 'returns hash representation' do
      result = expiration_chain.to_h
      expect(result).to be_a(Hash)
      expect(result).to have_key('expirationList')
      expect(result).to have_key('status')
      expect(result['expirationList']).to be_an(Array)
    end

    it 'includes all expiration data' do
      result = expiration_chain.to_h
      expect(result['expirationList'].first).to include(
        'expirationDate' => '2025-07-21',
        'daysToExpiration' => 1,
        'expirationType' => 'W',
        'settlementType' => 'P',
        'optionRoots' => 'SPY',
        'standard' => true
      )
    end
  end

  describe '#find_by_date' do
    it 'finds expiration by date string' do
      expiration = expiration_chain.find_by_date('2025-07-21')
      expect(expiration).to be_a(SchwabRb::DataObjects::OptionExpirationChain::Expiration)
      expect(expiration.expiration_date).to eq('2025-07-21')
    end

    it 'finds expiration by Date object' do
      date = Date.new(2025, 7, 21)
      expiration = expiration_chain.find_by_date(date)
      expect(expiration).to be_a(SchwabRb::DataObjects::OptionExpirationChain::Expiration)
      expect(expiration.expiration_date).to eq('2025-07-21')
    end

    it 'returns nil for non-existent date' do
      expiration = expiration_chain.find_by_date('2025-01-01')
      expect(expiration).to be_nil
    end
  end

  describe '#find_by_days_to_expiration' do
    it 'finds expirations by days to expiration' do
      expirations = expiration_chain.find_by_days_to_expiration(1)
      expect(expirations).to be_an(Array)
      expect(expirations.length).to eq(1)
      expect(expirations.first.days_to_expiration).to eq(1)
    end

    it 'returns empty array for non-existent days' do
      expirations = expiration_chain.find_by_days_to_expiration(9999)
      expect(expirations).to eq([])
    end
  end

  describe '#weekly_expirations' do
    it 'returns only weekly expirations' do
      weekly = expiration_chain.weekly_expirations
      expect(weekly).to all(be_a(SchwabRb::DataObjects::OptionExpirationChain::Expiration))
      expect(weekly).to all(satisfy { |exp| exp.expiration_type == 'W' })
      expect(weekly.length).to be > 0
    end
  end

  describe '#monthly_expirations' do
    it 'returns only monthly expirations' do
      monthly = expiration_chain.monthly_expirations
      expect(monthly).to all(be_a(SchwabRb::DataObjects::OptionExpirationChain::Expiration))
      expect(monthly).to all(satisfy { |exp| exp.expiration_type == 'M' })
    end
  end

  describe '#quarterly_expirations' do
    it 'returns only quarterly expirations' do
      quarterly = expiration_chain.quarterly_expirations
      expect(quarterly).to all(be_a(SchwabRb::DataObjects::OptionExpirationChain::Expiration))
      expect(quarterly).to all(satisfy { |exp| exp.expiration_type == 'Q' })
    end
  end

  describe '#standard_expirations' do
    it 'returns only standard expirations' do
      standard = expiration_chain.standard_expirations
      expect(standard).to all(be_a(SchwabRb::DataObjects::OptionExpirationChain::Expiration))
      expect(standard).to all(satisfy(&:standard?))
    end
  end

  describe '#non_standard_expirations' do
    it 'returns only non-standard expirations' do
      non_standard = expiration_chain.non_standard_expirations
      expect(non_standard).to all(be_a(SchwabRb::DataObjects::OptionExpirationChain::Expiration))
      expect(non_standard).to all(satisfy { |exp| !exp.standard? })
    end
  end

  describe '#count, #size, #length' do
    it 'returns the number of expirations' do
      count = expiration_chain.count
      expect(count).to be > 0
      expect(expiration_chain.size).to eq(count)
      expect(expiration_chain.length).to eq(count)
    end
  end

  describe '#empty?' do
    it 'returns false when expirations exist' do
      expect(expiration_chain.empty?).to be(false)
    end

    it 'returns true when no expirations exist' do
      empty_chain = described_class.new({})
      expect(empty_chain.empty?).to be(true)
    end
  end

  describe '#each' do
    it 'iterates over expirations' do
      count = 0
      expiration_chain.each do |expiration|
        expect(expiration).to be_a(SchwabRb::DataObjects::OptionExpirationChain::Expiration)
        count += 1
      end
      expect(count).to eq(expiration_chain.count)
    end

    it 'returns enumerator when no block given' do
      enum = expiration_chain.each
      expect(enum).to be_a(Enumerator)
    end
  end

  describe 'Enumerable methods' do
    it 'supports map' do
      dates = expiration_chain.map(&:expiration_date)
      expect(dates).to be_an(Array)
      expect(dates.first).to eq('2025-07-21')
    end

    it 'supports select' do
      weekly = expiration_chain.select(&:weekly?)
      expect(weekly).to all(satisfy(&:weekly?))
    end
  end

  describe SchwabRb::DataObjects::OptionExpirationChain::Expiration do
    let(:expiration_data) do
      {
        'expirationDate' => '2025-07-21',
        'daysToExpiration' => 1,
        'expirationType' => 'W',
        'settlementType' => 'P',
        'optionRoots' => 'SPY',
        'standard' => true
      }
    end
    let(:expiration) { described_class.new(expiration_data) }

    describe '#initialize' do
      it 'initializes with expiration data' do
        expect(expiration.expiration_date).to eq('2025-07-21')
        expect(expiration.days_to_expiration).to eq(1)
        expect(expiration.expiration_type).to eq('W')
        expect(expiration.settlement_type).to eq('P')
        expect(expiration.option_roots).to eq('SPY')
        expect(expiration.standard).to be(true)
      end
    end

    describe '#to_h' do
      it 'returns hash representation' do
        result = expiration.to_h
        expect(result).to eq(expiration_data)
      end
    end

    describe '#standard?' do
      it 'returns true for standard expiration' do
        expect(expiration.standard?).to be(true)
      end

      it 'returns false for non-standard expiration' do
        non_standard = described_class.new(expiration_data.merge('standard' => false))
        expect(non_standard.standard?).to be(false)
      end
    end

    describe 'expiration type predicates' do
      it '#weekly? returns true for weekly expiration' do
        expect(expiration.weekly?).to be(true)
      end

      it '#monthly? returns true for monthly expiration' do
        monthly = described_class.new(expiration_data.merge('expirationType' => 'M'))
        expect(monthly.monthly?).to be(true)
      end

      it '#quarterly? returns true for quarterly expiration' do
        quarterly = described_class.new(expiration_data.merge('expirationType' => 'Q'))
        expect(quarterly.quarterly?).to be(true)
      end

      it '#special? returns true for special expiration' do
        special = described_class.new(expiration_data.merge('expirationType' => 'S'))
        expect(special.special?).to be(true)
      end
    end

    describe '#date_object' do
      it 'returns Date object' do
        date = expiration.date_object
        expect(date).to be_a(Date)
        expect(date.year).to eq(2025)
        expect(date.month).to eq(7)
        expect(date.day).to eq(21)
      end

      it 'handles nil expiration date' do
        exp = described_class.new(expiration_data.merge('expirationDate' => nil))
        expect(exp.date_object).to be_nil
      end
    end

    describe '#expires_in_days?' do
      it 'returns true when days match' do
        expect(expiration.expires_in_days?(1)).to be(true)
        expect(expiration.expires_in_days?(2)).to be(false)
      end
    end

    describe '#expires_today?' do
      it 'returns true for 0 days to expiration' do
        today_exp = described_class.new(expiration_data.merge('daysToExpiration' => 0))
        expect(today_exp.expires_today?).to be(true)
        expect(expiration.expires_today?).to be(false)
      end
    end

    describe '#expires_tomorrow?' do
      it 'returns true for 1 day to expiration' do
        expect(expiration.expires_tomorrow?).to be(true)
        
        tomorrow_exp = described_class.new(expiration_data.merge('daysToExpiration' => 2))
        expect(tomorrow_exp.expires_tomorrow?).to be(false)
      end
    end
  end
end
