# frozen_string_literal: true

require "csv"
require "json"
require "time"
require "fileutils"

module SchwabRb
  class OptionSample
    # Public file-oriented downloader for one-expiration option chain samples.
    module Downloader
      SUPPORTED_FORMATS = %w[csv json].freeze
      CSV_HEADERS = %w[
        contract_type
        symbol
        description
        strike
        expiration_date
        mark
        bid
        bid_size
        ask
        ask_size
        last
        last_size
        open_interest
        total_volume
        delta
        gamma
        theta
        vega
        rho
        volatility
        theoretical_volatility
        theoretical_option_value
        intrinsic_value
        extrinsic_value
        underlying_price
      ].freeze

      module_function

      # rubocop:disable Metrics/ParameterLists
      def resolve(client:, symbol:, expiration_date:, directory:, format:, timestamp:, root: nil)
        response = fetch(
          client: client,
          symbol: symbol,
          expiration_date: expiration_date,
          root: root
        )

        FileUtils.mkdir_p(directory)
        path = output_path(
          directory: directory,
          symbol: symbol,
          expiration_date: expiration_date,
          format: format,
          timestamp: timestamp,
          root: root,
          response: response
        )
        File.write(path, serialize(response: response, format: format, timestamp: timestamp))

        [response, path]
      end
      # rubocop:enable Metrics/ParameterLists

      def fetch(client:, symbol:, expiration_date:, root: nil)
        response = client.get_option_chain(
          SchwabRb::PriceHistory::Downloader.api_symbol(symbol),
          contract_type: SchwabRb::Option::ContractTypes::ALL,
          strike_range: SchwabRb::Option::StrikeRanges::ALL,
          from_date: expiration_date,
          to_date: expiration_date,
          return_data_objects: false
        )

        filter_response_by_root(response, root)
      end

      def filter_response_by_root(response, option_root)
        return response if blank?(option_root)

        normalized_root = option_root.to_s.strip.upcase

        response.merge(
          callExpDateMap: filter_date_map_by_root(response[:callExpDateMap], normalized_root),
          putExpDateMap: filter_date_map_by_root(response[:putExpDateMap], normalized_root)
        )
      end

      def filter_date_map_by_root(date_map, option_root)
        return {} unless date_map

        date_map.each_with_object({}) do |(expiration_key, strikes), filtered_dates|
          filtered_strikes = strikes.each_with_object({}) do |(strike, contracts), filtered_by_strike|
            matching_contracts = contracts.select { |contract| contract[:optionRoot].to_s.upcase == option_root }
            filtered_by_strike[strike] = matching_contracts if matching_contracts.any?
          end

          filtered_dates[expiration_key] = filtered_strikes if filtered_strikes.any?
        end
      end

      # rubocop:disable Metrics/ParameterLists
      def output_path(directory:, symbol:, expiration_date:, format:, timestamp:, root: nil, response: nil)
        selected_root = root || option_root(response, symbol)

        File.join(
          directory,
          [
            SchwabRb::PriceHistory::Downloader.sanitize_symbol(selected_root),
            "exp#{expiration_date.iso8601}",
            timestamp.strftime("%Y-%m-%d_%H-%M-%S")
          ].join("_") + ".#{format}"
        )
      end
      # rubocop:enable Metrics/ParameterLists

      def serialize(response:, format:, timestamp:)
        case format
        when "json"
          JSON.pretty_generate(response)
        when "csv"
          serialize_csv(response: response, timestamp: timestamp)
        else
          raise ArgumentError, "Unsupported format `#{format}`."
        end
      end

      def serialize_csv(response:, timestamp:)
        sample_timestamp = timestamp.utc.iso8601

        CSV.generate do |csv|
          csv << CSV_HEADERS
          rows(response).each do |option|
            csv << csv_row(response, option, sample_timestamp)
          end
        end
      end

      # rubocop:disable Metrics/AbcSize
      def csv_row(response, option, _sample_timestamp)
        [
          option[:putCall],
          option[:symbol],
          option[:description],
          option[:strikePrice],
          normalize_option_date(option[:expirationDate]),
          option[:mark],
          option[:bid],
          option[:bidSize],
          option[:ask],
          option[:askSize],
          option[:last],
          option[:lastSize],
          option[:openInterest],
          option[:totalVolume],
          option[:delta],
          option[:gamma],
          option[:theta],
          option[:vega],
          option[:rho],
          option[:volatility],
          option[:theoreticalVolatility],
          option[:theoreticalOptionValue],
          option[:intrinsicValue],
          option[:extrinsicValue],
          response[:underlyingPrice]
        ]
      end
      # rubocop:enable Metrics/AbcSize

      def rows(response)
        extracted_rows = [response[:callExpDateMap], response[:putExpDateMap]].compact.flat_map do |date_map|
          rows_from_date_map(date_map)
        end

        extracted_rows.sort_by do |option|
          [
            normalize_option_date(option[:expirationDate]).to_s,
            option[:putCall].to_s,
            option[:strikePrice].to_f
          ]
        end
      end

      def rows_from_date_map(date_map)
        date_map.values.flat_map do |strikes|
          strikes.values.flatten.map { |option| option.transform_keys(&:to_sym) }
        end
      end

      def option_root(response, fallback_symbol)
        first_option = rows(response).find { |option| !blank?(option[:optionRoot]) }
        first_option ? first_option[:optionRoot] : fallback_symbol
      end

      def normalize_option_date(value)
        return if value.nil?

        Date.parse(value.to_s).iso8601
      end

      def blank?(value)
        value.nil? || value.to_s.strip.empty?
      end
    end
  end
end
