# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/schwab_rb/utils/enum_enforcer"

class DummyClass
  include EnumEnforcer

  def initialize(enforce_enums: true)
    @enforce_enums = enforce_enums
  end

  attr_reader :enforce_enums
end

describe SchwabRb::Account do
  let(:dummy_enforce) { DummyClass.new(enforce_enums: true) }
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
  it "returns correct fields" do
    expect(
      dummy_enforce.get_valid_enum_values(SchwabRb::Account::Statuses)
    ).to eq(["positions"])
  end
end
