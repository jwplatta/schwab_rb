require "spec_helper"

describe SchwabRb::Movers do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
  describe 'constants' do
    it 'returns correct indexes' do
      expect(described_class.indexes).to match_array([
        '$DJI', '$COMPX', '$SPX', 'NYSE', 'NASDAQ', 'OTCBB', 'INDEX_ALL', 'EQUITY_ALL', 'OPTION_ALL', 'OPTION_PUT', 'OPTION_CALL'
      ])
    end
    it 'returns correct sort orders' do
      expect(described_class.sort_orders).to match_array([
        'VOLUME', 'TRADES', 'PERCENT_CHANGE_UP', 'PERCENT_CHANGE_DOWN'
      ])
    end
    it 'returns correct frequencies' do
      expect(described_class.frequencies).to match_array([0, 1, 5, 10, 30, 60])
    end
  end
end
