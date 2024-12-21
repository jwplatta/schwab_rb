require "spec_helper"

describe SchwabRb::Order do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
  describe 'constants' do
    it 'returns correct statuses' do
      statuses = SchwabRb::Order::Status.constants.map { |const| SchwabRb::Order::Status.const_get(const) }
      expect(described_class.statuses).to match_array(statuses)
    end
    it 'returns correct types' do
      types = SchwabRb::Order::Type.constants.map { |const| SchwabRb::Order::Type.const_get(const) }
      expect(described_class.types).to match_array(types)
    end
  end
end
