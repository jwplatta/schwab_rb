require "spec_helper"
require_relative "../../lib/schwab_rb/utils/enum_enforcer"

class DummyClass
  include EnumEnforcer

  def initialize(enforce_enums: true)
    @enforce_enums = enforce_enums
  end

  attr_reader :enforce_enums
end

describe EnumEnforcer do
  let(:dummy_enforce) { DummyClass.new(enforce_enums: true) }
  let(:dummy_ignore) { DummyClass.new(enforce_enums: false) }

  describe "#convert_enum" do
    it "returns the value if it is a valid enum" do
      expect(
        dummy_enforce.convert_enum(
          SchwabRb::Order::Statuses::WORKING,
          SchwabRb::Order::Statuses
        )
      ).to eq(SchwabRb::Order::Statuses::WORKING)
    end

    it "raises an error if enforce_enums is true and value is invalid" do
      expect do
        dummy_enforce.convert_enum("invalid", SchwabRb::Order::Statuses)
      end.to raise_error(ArgumentError)
    end

    it "returns the value if enforce_enums is false and value is invalid" do
      expect(dummy_ignore.convert_enum(
               "invalid",
               SchwabRb::Order::Statuses
             )).to eq("invalid")
    end
  end

  describe "#convert_enum_iterable" do
    it "returns an array with the value if it is a valid enum" do
      expect(
        dummy_enforce.convert_enum_iterable(
          [SchwabRb::Order::Statuses::WORKING],
          SchwabRb::Order::Statuses
        )
      ).to eq([SchwabRb::Order::Statuses::WORKING])
    end

    it "raises an error if enforce_enums is true and any value is invalid" do
      expect do
        dummy_enforce.convert_enum_iterable(
          ["invalid"],
          SchwabRb::Order::Statuses
        )
      end.to raise_error(ArgumentError)
    end

    it "returns the values if enforce_enums is false and any value is invalid" do
      expect(
        dummy_ignore.convert_enum_iterable(
          ["invalid"],
          SchwabRb::Order::Statuses
        )
      ).to eq(["invalid"])
    end
  end
end
