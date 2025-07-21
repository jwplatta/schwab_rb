require "spec_helper"
require_relative "../lib/schwab_rb/utils/enum_enforcer"

class DummyClass
  include EnumEnforcer

  def initialize(enforce_enums: true)
    @enforce_enums = enforce_enums
  end

  attr_reader :enforce_enums
end

describe SchwabRb::Movers do
  let(:dummy_enforce) { DummyClass.new(enforce_enums: true) }
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
  describe "constants" do
    it "returns correct indexes" do
      expect(
        dummy_enforce.get_valid_enum_values(described_class::Indexes)
      ).to match_array([
                         "$DJI", "$COMPX", "$SPX", "NYSE", "NASDAQ", "OTCBB", "INDEX_ALL", "EQUITY_ALL", "OPTION_ALL", "OPTION_PUT", "OPTION_CALL"
                       ])
    end
    it "returns correct sort orders" do
      expect(
        dummy_enforce.get_valid_enum_values(described_class::SortOrders)
      ).to match_array(%w[
                         VOLUME TRADES PERCENT_CHANGE_UP PERCENT_CHANGE_DOWN
                       ])
    end
    it "returns correct frequencies" do
      expect(dummy_enforce.get_valid_enum_values(described_class::Frequencies)).to match_array([0, 1, 5, 10, 30, 60])
    end
  end
end
