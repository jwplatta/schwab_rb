require "spec_helper"

describe SchwabRb::PriceHistory do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
end
