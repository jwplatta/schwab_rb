# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

describe SchwabRb::PriceHistory::Downloader do
  describe ".resolve" do
    it "writes csv output and reuses the cached file when already covered" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "SPX_day.csv")
        File.write(
          path,
          <<~CSV
            datetime,open,high,low,close,volume
            2026-04-01T00:00:00Z,10.0,11.0,9.0,10.5,100
            2026-04-02T00:00:00Z,11.0,12.0,10.0,11.5,110
          CSV
        )

        client = double("client")
        allow(client).to receive(:get_price_history)

        response, output_path = described_class.resolve(
          client: client,
          symbol: "SPX",
          start_date: Date.new(2026, 4, 1),
          end_date: Date.new(2026, 4, 2),
          directory: dir,
          frequency: "day",
          format: "csv",
          need_extended_hours_data: false,
          need_previous_close: false
        )

        expect(client).not_to have_received(:get_price_history)
        expect(output_path).to eq(path)
        expect(response[:candles].size).to eq(2)
      end
    end
  end

  describe ".canonical_output_path" do
    it "uses the raw symbol in the file name" do
      path = described_class.canonical_output_path(
        directory: "/tmp/history",
        symbol: "$SPX",
        frequency: "5min",
        format: "csv"
      )

      expect(path).to eq("/tmp/history/SPX_5min.csv")
    end
  end
end
