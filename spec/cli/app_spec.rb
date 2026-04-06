# frozen_string_literal: true

require "spec_helper"
require "stringio"
require "tmpdir"

describe SchwabRb::CLI::App do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  let(:env) do
    {
      "SCHWAB_API_KEY" => "api-key",
      "SCHWAB_APP_SECRET" => "app-secret",
      "SCHWAB_APP_CALLBACK_URL" => "https://127.0.0.1:8182",
      "HOME" => Dir.home
    }
  end
  let(:app) { described_class.new(env: env, stdout: stdout, stderr: stderr) }

  describe "#call" do
    it "prints top-level help" do
      status = app.call(["help"])

      expect(status).to eq(0)
      expect(stdout.string).to include("Usage: schwab_rb COMMAND [options]")
      expect(stdout.string).to include("price-history")
    end

    it "passes the shared token path to login" do
      allow(SchwabRb::Auth).to receive(:init_client_login).and_return(double("client"))

      status = app.call(["login"])

      expect(status).to eq(0)
      expect(SchwabRb::Auth).to have_received(:init_client_login).with(
        "api-key",
        "app-secret",
        "https://127.0.0.1:8182",
        File.expand_path("~/.schwab_rb/token.json")
      )
      expect(stdout.string).to include("Authentication succeeded")
    end

    it "maps frequency aliases and writes json output" do
      Dir.mktmpdir do |dir|
        client = double("client", session: double("session", expired?: false))
        response = { symbol: "VIX", candles: [] }
        allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
        allow(client).to receive(:refresh!)
        allow(client).to receive(:get_price_history).and_return(response)

        status = app.call(
          [
            "price-history",
            "--symbol", "VIX",
            "--start-date", "2026-03-17",
            "--end-date", "2026-03-24",
            "--freq", "1min",
            "--dir", dir
          ]
        )

        expect(status).to eq(0)
        expect(client).to have_received(:get_price_history).with(
          "$VIX",
          period_type: SchwabRb::PriceHistory::PeriodTypes::DAY,
          period: SchwabRb::PriceHistory::Periods::ONE_DAY,
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::MINUTE,
          frequency: SchwabRb::PriceHistory::Frequencies::EVERY_MINUTE,
          start_datetime: Date.new(2026, 3, 17),
          end_datetime: Date.new(2026, 3, 24),
          need_extended_hours_data: false,
          need_previous_close: false,
          return_data_objects: false
        )

        expected_path = File.join(dir, "VIX_1min.json")
        expect(File).to exist(expected_path)
        expect(stdout.string).to include(expected_path)
      end
    end

    it "uses the index api symbol but keeps the raw symbol in the file name" do
      Dir.mktmpdir do |dir|
        client = double("client", session: double("session", expired?: false))
        allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
        allow(client).to receive(:refresh!)
        allow(client).to receive(:get_price_history).and_return(symbol: "$SPX", candles: [])

        status = app.call(
          [
            "price-history",
            "--symbol", "SPX",
            "--start-date", "2026-03-17",
            "--end-date", "2026-03-24",
            "--freq", "day",
            "--dir", dir
          ]
        )

        expect(status).to eq(0)
        expect(client).to have_received(:get_price_history).with(
          "$SPX",
          period_type: SchwabRb::PriceHistory::PeriodTypes::YEAR,
          period: SchwabRb::PriceHistory::Periods::TWENTY_YEARS,
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::DAILY,
          frequency: SchwabRb::PriceHistory::Frequencies::DAILY,
          start_datetime: Date.new(2026, 3, 17),
          end_datetime: Date.new(2026, 3, 24),
          need_extended_hours_data: false,
          need_previous_close: false,
          return_data_objects: false
        )
        expect(File).to exist(File.join(dir, "SPX_day.json"))
      end
    end

    it "passes futures symbols through to the api unchanged" do
      Dir.mktmpdir do |dir|
        client = double("client", session: double("session", expired?: false))
        allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
        allow(client).to receive(:refresh!)
        allow(client).to receive(:get_price_history).and_return(symbol: "/ES", candles: [])

        status = app.call(
          [
            "price-history",
            "--symbol", "/ES",
            "--start-date", "2026-03-17",
            "--end-date", "2026-03-24",
            "--freq", "day",
            "--dir", dir
          ]
        )

        expect(status).to eq(0)
        expect(client).to have_received(:get_price_history).with(
          "/ES",
          period_type: SchwabRb::PriceHistory::PeriodTypes::YEAR,
          period: SchwabRb::PriceHistory::Periods::TWENTY_YEARS,
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::DAILY,
          frequency: SchwabRb::PriceHistory::Frequencies::DAILY,
          start_datetime: Date.new(2026, 3, 17),
          end_datetime: Date.new(2026, 3, 24),
          need_extended_hours_data: false,
          need_previous_close: false,
          return_data_objects: false
        )
      end
    end

    it "writes CSV candle output" do
      Dir.mktmpdir do |dir|
        client = double("client", session: double("session", expired?: false))
        allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
        allow(client).to receive(:refresh!)
        allow(client).to receive(:get_price_history).and_return(
          {
            symbol: "AAPL",
            candles: [
              {
                datetime: 1_711_078_400_000,
                open: 100.0,
                high: 101.0,
                low: 99.5,
                close: 100.5,
                volume: 1234
              }
            ]
          }
        )

        status = app.call(
          [
            "price-history",
            "--symbol", "AAPL",
            "--start-date", "2026-03-17",
            "--format", "csv",
            "--dir", dir
          ]
        )

        expect(status).to eq(0)
        output = File.read(File.join(dir, "AAPL_day.csv"))
        expect(output).to include("datetime,open,high,low,close,volume")
        expect(output).to include("2024-03-22T03:33:20Z,100.0,101.0,99.5,100.5,1234")
      end
    end

    it "uses yesterday when end date would otherwise be today" do
      Dir.mktmpdir do |dir|
        client = double("client", session: double("session", expired?: false))
        allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
        allow(client).to receive(:refresh!)
        allow(client).to receive(:get_price_history).and_return(symbol: "VIX", candles: [])

        status = app.call(
          [
            "price-history",
            "--symbol", "VIX",
            "--start-date", (Date.today - 5).iso8601,
            "--freq", "day",
            "--dir", dir
          ]
        )

        expect(status).to eq(0)
        expect(client).to have_received(:get_price_history).with(
          "$VIX",
          period_type: SchwabRb::PriceHistory::PeriodTypes::YEAR,
          period: SchwabRb::PriceHistory::Periods::TWENTY_YEARS,
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::DAILY,
          frequency: SchwabRb::PriceHistory::Frequencies::DAILY,
          start_datetime: Date.today - 5,
          end_datetime: Date.today - 1,
          need_extended_hours_data: false,
          need_previous_close: false,
          return_data_objects: false
        )
      end
    end

    it "skips the API call when the requested range is already cached" do
      Dir.mktmpdir do |dir|
        cached_path = File.join(dir, "SPX_5min.json")
        File.write(
          cached_path,
          JSON.pretty_generate(
            {
              symbol: "SPX",
              candles: [
                { datetime: Time.utc(2026, 3, 17, 14, 30).to_i * 1000, open: 1, high: 1, low: 1, close: 1, volume: 10 },
                { datetime: Time.utc(2026, 3, 24, 20, 0).to_i * 1000, open: 2, high: 2, low: 2, close: 2, volume: 20 }
              ]
            }
          )
        )

        client = double("client", session: double("session", expired?: false))
        allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
        allow(client).to receive(:refresh!)
        allow(client).to receive(:get_price_history)

        status = app.call(
          [
            "price-history",
            "--symbol", "SPX",
            "--start-date", "2026-03-17",
            "--end-date", "2026-03-24",
            "--freq", "5min",
            "--dir", dir
          ]
        )

        expect(status).to eq(0)
        expect(client).not_to have_received(:get_price_history)
        expect(stdout.string).to include(cached_path)
      end
    end

    it "fetches only the missing range and merges it into the cache" do
      Dir.mktmpdir do |dir|
        cached_path = File.join(dir, "SPX_5min.json")
        File.write(
          cached_path,
          JSON.pretty_generate(
            {
              symbol: "SPX",
              candles: [
                { datetime: Time.utc(2026, 3, 20, 14, 30).to_i * 1000, open: 10, high: 11, low: 9, close: 10.5, volume: 100 },
                { datetime: Time.utc(2026, 3, 24, 20, 0).to_i * 1000, open: 20, high: 21, low: 19, close: 20.5, volume: 200 }
              ]
            }
          )
        )

        client = double("client", session: double("session", expired?: false))
        allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
        allow(client).to receive(:refresh!)
        allow(client).to receive(:get_price_history).and_return(
          {
            symbol: "SPX",
            candles: [
              { datetime: Time.utc(2026, 3, 17, 14, 30).to_i * 1000, open: 1, high: 2, low: 0.5, close: 1.5, volume: 50 },
              { datetime: Time.utc(2026, 3, 20, 14, 30).to_i * 1000, open: 99, high: 99, low: 99, close: 99, volume: 999 }
            ]
          }
        )

        status = app.call(
          [
            "price-history",
            "--symbol", "SPX",
            "--start-date", "2026-03-17",
            "--end-date", "2026-03-24",
            "--freq", "5min",
            "--dir", dir
          ]
        )

        expect(status).to eq(0)
        expect(client).to have_received(:get_price_history).with(
          "$SPX",
          period_type: SchwabRb::PriceHistory::PeriodTypes::DAY,
          period: SchwabRb::PriceHistory::Periods::ONE_DAY,
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::MINUTE,
          frequency: SchwabRb::PriceHistory::Frequencies::EVERY_FIVE_MINUTES,
          start_datetime: Date.new(2026, 3, 17),
          end_datetime: Date.new(2026, 3, 24),
          need_extended_hours_data: false,
          need_previous_close: false,
          return_data_objects: false
        )

        merged_output = JSON.parse(File.read(File.join(dir, "SPX_5min.json")))
        expect(merged_output.fetch("candles").map { |candle| candle.fetch("datetime") }).to eq(
          [
            Time.utc(2026, 3, 17, 14, 30).to_i * 1000,
            Time.utc(2026, 3, 20, 14, 30).to_i * 1000,
            Time.utc(2026, 3, 24, 20, 0).to_i * 1000
          ]
        )
        expect(
          merged_output.fetch("candles").find { |candle| candle.fetch("datetime") == Time.utc(2026, 3, 20, 14, 30).to_i * 1000 }
        ).to include("open" => 99)
      end
    end

    it "fetches missing interior daily dates and merges them into the cache" do
      Dir.mktmpdir do |dir|
        cached_path = File.join(dir, "VIX_day.csv")
        File.write(
          cached_path,
          <<~CSV
            datetime,open,high,low,close,volume
            2026-04-01T00:00:00Z,10.0,11.0,9.0,10.5,100
            2026-04-03T00:00:00Z,12.0,13.0,11.0,12.5,120
          CSV
        )

        client = double("client", session: double("session", expired?: false))
        allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
        allow(client).to receive(:refresh!)
        allow(client).to receive(:get_price_history).and_return(
          {
            symbol: "VIX",
            candles: [
              { datetime: Time.utc(2026, 4, 2).to_i * 1000, open: 11.0, high: 12.0, low: 10.0, close: 11.5, volume: 110 }
            ]
          }
        )

        status = app.call(
          [
            "price-history",
            "--symbol", "VIX",
            "--start-date", "2026-04-01",
            "--end-date", "2026-04-03",
            "--freq", "day",
            "--format", "csv",
            "--dir", dir
          ]
        )

        expect(status).to eq(0)
        expect(client).to have_received(:get_price_history).with(
          "$VIX",
          period_type: SchwabRb::PriceHistory::PeriodTypes::YEAR,
          period: SchwabRb::PriceHistory::Periods::TWENTY_YEARS,
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::DAILY,
          frequency: SchwabRb::PriceHistory::Frequencies::DAILY,
          start_datetime: Date.new(2026, 4, 1),
          end_datetime: Date.new(2026, 4, 3),
          need_extended_hours_data: false,
          need_previous_close: false,
          return_data_objects: false
        )

        output = File.read(cached_path)
        expect(output).to include("2026-04-01T00:00:00Z,10.0,11.0,9.0,10.5,100")
        expect(output).to include("2026-04-02T00:00:00Z,11.0,12.0,10.0,11.5,110")
        expect(output).to include("2026-04-03T00:00:00Z,12.0,13.0,11.0,12.5,120")
      end
    end

    it "treats a requested window with no cached overlap as fully missing" do
      Dir.mktmpdir do |dir|
        cached_path = File.join(dir, "VIX_day.csv")
        File.write(
          cached_path,
          <<~CSV
            datetime,open,high,low,close,volume
            2026-03-20T00:00:00Z,20.0,21.0,19.0,20.5,100
            2026-03-23T00:00:00Z,23.0,24.0,22.0,23.5,130
          CSV
        )

        client = double("client", session: double("session", expired?: false))
        allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
        allow(client).to receive(:refresh!)
        allow(client).to receive(:get_price_history).and_return(
          {
            symbol: "VIX",
            candles: [
              { datetime: Time.utc(2026, 4, 1).to_i * 1000, open: 30.0, high: 31.0, low: 29.0, close: 30.5, volume: 140 },
              { datetime: Time.utc(2026, 4, 2).to_i * 1000, open: 31.0, high: 32.0, low: 30.0, close: 31.5, volume: 150 }
            ]
          }
        )

        status = app.call(
          [
            "price-history",
            "--symbol", "VIX",
            "--start-date", "2026-04-01",
            "--end-date", "2026-04-02",
            "--freq", "day",
            "--format", "csv",
            "--dir", dir
          ]
        )

        expect(status).to eq(0)
        expect(client).to have_received(:get_price_history).with(
          "$VIX",
          period_type: SchwabRb::PriceHistory::PeriodTypes::YEAR,
          period: SchwabRb::PriceHistory::Periods::TWENTY_YEARS,
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::DAILY,
          frequency: SchwabRb::PriceHistory::Frequencies::DAILY,
          start_datetime: Date.new(2026, 4, 1),
          end_datetime: Date.new(2026, 4, 2),
          need_extended_hours_data: false,
          need_previous_close: false,
          return_data_objects: false
        )

        output = File.read(cached_path)
        expect(output).to include("2026-03-20T00:00:00Z,20.0,21.0,19.0,20.5,100")
        expect(output).to include("2026-03-23T00:00:00Z,23.0,24.0,22.0,23.5,130")
        expect(output).to include("2026-04-01T00:00:00Z,30.0,31.0,29.0,30.5,140")
        expect(output).to include("2026-04-02T00:00:00Z,31.0,32.0,30.0,31.5,150")
      end
    end

    it "returns a login hint when the token is missing" do
      allow(SchwabRb::Auth).to receive(:init_client_token_file).and_raise(Errno::ENOENT)

      status = app.call(
        [
          "price-history",
          "--symbol", "AAPL",
          "--start-date", "2026-03-17"
        ]
      )

      expect(status).to eq(1)
      expect(stderr.string).to include("Run `schwab_rb login`")
    end
  end
end
