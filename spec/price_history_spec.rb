# frozen_string_literal: true

require "spec_helper"

describe SchwabRb::PriceHistory do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
  describe "constants" do
    it "returns correct period types" do
      period_types = SchwabRb::PriceHistory::PeriodTypes.constants.map do |const|
        SchwabRb::PriceHistory::PeriodTypes.const_get(const)
      end
      expect(period_types).to match_array(%w[day month year ytd])
    end

    it "returns correct periods" do
      periods = SchwabRb::PriceHistory::Periods.constants.map do |const|
        SchwabRb::PriceHistory::Periods.const_get(const)
      end
      expect(periods).to match_array([1, 2, 3, 4, 5, 10, 1, 2, 3, 6, 1, 2, 3, 5, 10, 15, 20, 1])
    end

    it "returns correct frequency types" do
      frequency_types = SchwabRb::PriceHistory::FrequencyTypes.constants.map do |const|
        SchwabRb::PriceHistory::FrequencyTypes.const_get(const)
      end
      expect(frequency_types).to match_array(%w[minute daily weekly monthly])
    end

    it "returns correct frequencies" do
      frequencies = SchwabRb::PriceHistory::Frequencies.constants.map do |const|
        SchwabRb::PriceHistory::Frequencies.const_get(const)
      end
      expect(frequencies).to match_array([1, 5, 10, 15, 30, 1, 1, 1])
    end
  end
end
