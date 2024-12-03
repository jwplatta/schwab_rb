require "spec_helper"

describe SchwabRb::Client do
  fit "does not raise" do
    expect { described_class.new(nil, nil, token_metadata: nil) }.not_to raise_error
  end
end
