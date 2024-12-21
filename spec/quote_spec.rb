require "spec_helper"

describe SchwabRb::Quote do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end

  it "returns types" do
    expect(described_class.types).to match_array(%w(quote fundamental extended reference regular))
  end
end
