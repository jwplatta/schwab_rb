# frozen_string_literal: true

require "spec_helper"
require "stringio"
require "tmpdir"

describe SchwabRb::CLI::App do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  let(:sampled_at) { Time.utc(2025, 12, 29, 17, 24, 33) }
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
      expect(stdout.string).to include("sample")
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

    it "uses the history directory by default for price history" do
      client = double("client", session: double("session", expired?: false))
      allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
      allow(client).to receive(:refresh!)
      allow(client).to receive(:get_price_history).and_return(symbol: "AAPL", candles: [])
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:write)

      status = app.call(
        [
          "price-history",
          "--symbol", "AAPL",
          "--start-date", "2026-03-17"
        ]
      )

      expect(status).to eq(0)
      expect(FileUtils).to have_received(:mkdir_p).with(File.expand_path("~/.schwab_rb/data/history"))
      expect(File).to have_received(:write).with(
        File.expand_path("~/.schwab_rb/data/history/AAPL_day.json"),
        kind_of(String)
      )
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

    it "writes a csv option sample for one expiration" do
      Dir.mktmpdir do |dir|
        client = double("client", session: double("session", expired?: false))
        allow(Time).to receive(:now).and_return(sampled_at)
        allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
        allow(client).to receive(:refresh!)
        allow(client).to receive(:get_option_chain).and_return(
          {
            symbol: "$SPX",
            status: "SUCCESS",
            callExpDateMap: {
              "2025-12-29:0" => {
                "6000.0" => [
                  {
                    symbol: "SPX  251229C06000000",
                    expirationDate: "2025-12-29T06:00:00+0000",
                    putCall: "CALL",
                    optionRoot: "SPX",
                    strikePrice: 6000.0,
                    bid: 99.0,
                    bidSize: 1,
                    ask: 100.0,
                    askSize: 1,
                    last: 99.5,
                    lastSize: 1,
                    mark: 99.5,
                    delta: 0.5,
                    gamma: 0.01,
                    theta: -0.1,
                    vega: 0.1,
                    rho: 0.01,
                    volatility: 10.0,
                    theoreticalVolatility: 10.0,
                    theoreticalOptionValue: 99.5,
                    intrinsicValue: 0.0,
                    extrinsicValue: 99.5,
                    totalVolume: 1,
                    openInterest: 1,
                    description: "SPX Dec 29 2025 6000 Call"
                  },
                  {
                    symbol: "SPXW  251229C06000000",
                    expirationDate: "2025-12-29T06:00:00+0000",
                    putCall: "CALL",
                    optionRoot: "SPXW",
                    strikePrice: 6000.0,
                    bid: 10.0,
                    bidSize: 12,
                    ask: 10.5,
                    askSize: 14,
                    last: 10.25,
                    lastSize: 3,
                    mark: 10.25,
                    delta: 0.42,
                    gamma: 0.01,
                    theta: -0.2,
                    vega: 0.15,
                    rho: 0.03,
                    volatility: 18.5,
                    theoreticalVolatility: 19.0,
                    theoreticalOptionValue: 10.4,
                    intrinsicValue: 0.0,
                    extrinsicValue: 10.25,
                    totalVolume: 100,
                    openInterest: 200,
                    quoteTimeInLong: 1_767_029_073_000,
                    tradeTimeInLong: 1_767_029_000_000,
                    daysToExpiration: 0,
                    inTheMoney: false,
                    description: "SPXW Dec 29 2025 6000 Call"
                  }
                ]
              }
            },
            putExpDateMap: {
              "2025-12-29:0" => {
                "6000.0" => [
                  {
                    symbol: "SPXW  251229P06000000",
                    expirationDate: "2025-12-29T06:00:00+0000",
                    putCall: "PUT",
                    optionRoot: "SPXW",
                    strikePrice: 6000.0,
                    bid: 11.0,
                    bidSize: 8,
                    ask: 11.5,
                    askSize: 9,
                    last: 11.25,
                    lastSize: 2,
                    mark: 11.25,
                    delta: -0.58,
                    gamma: 0.02,
                    theta: -0.25,
                    vega: 0.18,
                    rho: -0.04,
                    volatility: 19.1,
                    theoreticalVolatility: 19.4,
                    theoreticalOptionValue: 11.3,
                    intrinsicValue: 3.5,
                    extrinsicValue: 7.75,
                    totalVolume: 150,
                    openInterest: 250,
                    quoteTimeInLong: 1_767_029_073_000,
                    tradeTimeInLong: 1_767_029_000_000,
                    daysToExpiration: 0,
                    inTheMoney: true,
                    description: "SPXW Dec 29 2025 6000 Put"
                  }
                ]
              }
            },
            underlyingPrice: 5996.5
          }
        )

        status = app.call(
          [
            "sample",
            "--symbol", "SPX",
            "--root", "SPXW",
            "--expiration-date", "2025-12-29",
            "--dir", dir
          ]
        )

        expect(status).to eq(0)
        expect(client).to have_received(:get_option_chain).with(
          "$SPX",
          contract_type: SchwabRb::Option::ContractTypes::ALL,
          strike_range: SchwabRb::Option::StrikeRanges::ALL,
          from_date: Date.new(2025, 12, 29),
          to_date: Date.new(2025, 12, 29),
          return_data_objects: false
        )

        expected_path = File.join(dir, "SPXW_exp2025-12-29_2025-12-29_17-24-33.csv")
        expect(File).to exist(expected_path)
        output = File.read(expected_path)
        expect(output).to include(
          "contract_type,symbol,description,strike,expiration_date,mark,bid,bid_size,ask,ask_size,last,last_size," \
          "open_interest,total_volume,delta,gamma,theta,vega,rho,volatility,theoretical_volatility," \
          "theoretical_option_value,intrinsic_value,extrinsic_value,underlying_price"
        )
        expect(output).to include(
          "CALL,SPXW  251229C06000000,SPXW Dec 29 2025 6000 Call,6000.0,2025-12-29,10.25,10.0,12,10.5,14,10.25,3," \
          "200,100,0.42,0.01,-0.2,0.15,0.03,18.5,19.0,10.4,0.0,10.25,5996.5"
        )
        expect(output).to include(
          "PUT,SPXW  251229P06000000,SPXW Dec 29 2025 6000 Put,6000.0,2025-12-29,11.25,11.0,8,11.5,9,11.25,2," \
          "250,150,-0.58,0.02,-0.25,0.18,-0.04,19.1,19.4,11.3,3.5,7.75,5996.5"
        )
        expect(output).not_to include("SPX  251229C06000000")
      end
    end

    it "writes json option samples to the options directory by default" do
      client = double("client", session: double("session", expired?: false))
      allow(Time).to receive(:now).and_return(sampled_at)
      allow(SchwabRb::Auth).to receive(:init_client_token_file).and_return(client)
      allow(client).to receive(:refresh!)
      allow(client).to receive(:get_option_chain).and_return(
        {
          symbol: "AAPL",
          status: "SUCCESS",
          callExpDateMap: {},
          putExpDateMap: {}
        }
      )
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:write)

      status = app.call(
        [
          "sample",
          "--symbol", "AAPL",
          "--expiration-date", "2025-12-29",
          "--format", "json"
        ]
      )

      expect(status).to eq(0)
      expect(FileUtils).to have_received(:mkdir_p).with(File.expand_path("~/.schwab_rb/data/options"))
      expect(File).to have_received(:write).with(
        File.expand_path("~/.schwab_rb/data/options/AAPL_exp2025-12-29_2025-12-29_17-24-33.json"),
        kind_of(String)
      )
    end

    it "requires an expiration date for option samples" do
      status = app.call(
        [
          "sample",
          "--symbol", "SPX"
        ]
      )

      expect(status).to eq(1)
      expect(stderr.string).to include("The `--expiration-date` option is required.")
    end
  end
end
