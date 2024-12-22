require "spec_helper"

describe SchwabRb::Account do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
  it "returns correct fields" do
    expect(described_class.statuses).to eq(["positions"])
  end
end