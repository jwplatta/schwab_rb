require "spec_helper"

RSpec.describe SchwabRb::PathSupport do
  describe ".expand_path" do
    it "raises for nil input" do
      expect { described_class.expand_path(nil) }
        .to raise_error(ArgumentError, "token_path is nil or empty")
    end

    it "raises for blank string input" do
      expect { described_class.expand_path("   ") }
        .to raise_error(ArgumentError, "token_path is nil or empty")
    end

    it "expands a valid path" do
      expect(described_class.expand_path("~/token.json")).to eq(File.expand_path("~/token.json"))
    end
  end
end
