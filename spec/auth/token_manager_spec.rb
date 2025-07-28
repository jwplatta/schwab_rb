# frozen_string_literal: true

require "spec_helper"

describe SchwabRb::Auth::TokenManager do
  it "does not raise error when subject is initialized" do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end
end
