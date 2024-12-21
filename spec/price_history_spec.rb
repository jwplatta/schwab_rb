require "spec_helper"

describe SchwabRb::PriceHistory do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
  describe 'constants' do
    it 'returns correct period types' do
      expect(described_class.period_types).to match_array(['day', 'month', 'year', 'ytd'])
    end

    it 'returns correct periods' do
      expect(described_class.periods).to match_array([1, 2, 3, 4, 5, 10, 1, 2, 3, 6, 1, 2, 3, 5, 10, 15, 20, 1])
    end

    it 'returns correct frequency types' do
      expect(described_class.frequency_types).to match_array(['minute', 'daily', 'weekly', 'monthly'])
    end

    it 'returns correct frequencies' do
      expect(described_class.frequencies).to match_array([1, 5, 10, 15, 30, 1, 1, 1])
    end
  end
end
