# frozen_string_literal: true

require "spec_helper"

describe SchwabRb::MarketHours do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
end
