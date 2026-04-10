# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

describe SchwabRb::OptionSample::Downloader do
  let(:sampled_at) { Time.utc(2025, 12, 29, 17, 24, 33) }
  let(:option_chain_response) do
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
              description: "SPXW Dec 29 2025 6000 Put"
            }
          ]
        }
      },
      underlyingPrice: 5996.5
    }
  end

  describe ".resolve" do
    it "normalizes the symbol, filters by root, and writes the existing csv payload" do
      Dir.mktmpdir do |dir|
        client = double("client")
        allow(client).to receive(:get_option_chain).and_return(option_chain_response)

        response, output_path = described_class.resolve(
          client: client,
          symbol: "SPX",
          root: "SPXW",
          expiration_date: Date.new(2025, 12, 29),
          directory: dir,
          format: "csv",
          timestamp: sampled_at
        )

        expect(client).to have_received(:get_option_chain).with(
          "$SPX",
          contract_type: SchwabRb::Option::ContractTypes::ALL,
          strike_range: SchwabRb::Option::StrikeRanges::ALL,
          from_date: Date.new(2025, 12, 29),
          to_date: Date.new(2025, 12, 29),
          return_data_objects: false
        )
        expect(output_path).to eq(File.join(dir, "SPXW_exp2025-12-29_2025-12-29_17-24-33.csv"))
        expect(response[:callExpDateMap].dig("2025-12-29:0", "6000.0").length).to eq(1)

        output = File.read(output_path)
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

    it "uses the symbol as the fallback output root for json output" do
      Dir.mktmpdir do |dir|
        client = double("client")
        allow(client).to receive(:get_option_chain).and_return(
          {
            symbol: "AAPL",
            status: "SUCCESS",
            callExpDateMap: {},
            putExpDateMap: {}
          }
        )

        _, output_path = described_class.resolve(
          client: client,
          symbol: "AAPL",
          expiration_date: Date.new(2025, 12, 29),
          directory: dir,
          format: "json",
          timestamp: sampled_at
        )

        expect(output_path).to eq(File.join(dir, "AAPL_exp2025-12-29_2025-12-29_17-24-33.json"))
        expect(JSON.parse(File.read(output_path))).to include("symbol" => "AAPL", "status" => "SUCCESS")
      end
    end
  end
end
