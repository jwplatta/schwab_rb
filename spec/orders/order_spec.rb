require "spec_helper"

describe SchwabRb::Order do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
end