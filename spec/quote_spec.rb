require "spec_helper"

describe SchwabRb::Quote do
  fit "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
end