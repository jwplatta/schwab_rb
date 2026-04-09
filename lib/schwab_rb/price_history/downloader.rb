# frozen_string_literal: true

require "csv"
require "json"
require "time"
require "fileutils"

module SchwabRb
  class PriceHistory
    module Downloader
      INDEX_API_SYMBOLS = %w[
        COMPX DJX MID NDX OEX RUT SPX VIX VIX9D VIX1D XSP
      ].freeze
      SUPPORTED_FORMATS = %w[csv json].freeze
      FREQUENCY_ALIASES = {
        "1min" => {
          label: "1min",
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::MINUTE,
          frequency: SchwabRb::PriceHistory::Frequencies::EVERY_MINUTE,
          period_type: SchwabRb::PriceHistory::PeriodTypes::DAY,
          period: SchwabRb::PriceHistory::Periods::ONE_DAY
        },
        "5min" => {
          label: "5min",
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::MINUTE,
          frequency: SchwabRb::PriceHistory::Frequencies::EVERY_FIVE_MINUTES,
          period_type: SchwabRb::PriceHistory::PeriodTypes::DAY,
          period: SchwabRb::PriceHistory::Periods::ONE_DAY
        },
        "10min" => {
          label: "10min",
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::MINUTE,
          frequency: SchwabRb::PriceHistory::Frequencies::EVERY_TEN_MINUTES,
          period_type: SchwabRb::PriceHistory::PeriodTypes::DAY,
          period: SchwabRb::PriceHistory::Periods::ONE_DAY
        },
        "15min" => {
          label: "15min",
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::MINUTE,
          frequency: SchwabRb::PriceHistory::Frequencies::EVERY_FIFTEEN_MINUTES,
          period_type: SchwabRb::PriceHistory::PeriodTypes::DAY,
          period: SchwabRb::PriceHistory::Periods::ONE_DAY
        },
        "30min" => {
          label: "30min",
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::MINUTE,
          frequency: SchwabRb::PriceHistory::Frequencies::EVERY_THIRTY_MINUTES,
          period_type: SchwabRb::PriceHistory::PeriodTypes::DAY,
          period: SchwabRb::PriceHistory::Periods::ONE_DAY
        },
        "day" => {
          label: "day",
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::DAILY,
          frequency: SchwabRb::PriceHistory::Frequencies::DAILY,
          period_type: SchwabRb::PriceHistory::PeriodTypes::YEAR,
          period: SchwabRb::PriceHistory::Periods::TWENTY_YEARS
        },
        "week" => {
          label: "week",
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::WEEKLY,
          frequency: SchwabRb::PriceHistory::Frequencies::WEEKLY,
          period_type: SchwabRb::PriceHistory::PeriodTypes::YEAR,
          period: SchwabRb::PriceHistory::Periods::TWENTY_YEARS
        },
        "month" => {
          label: "month",
          frequency_type: SchwabRb::PriceHistory::FrequencyTypes::MONTHLY,
          frequency: SchwabRb::PriceHistory::Frequencies::MONTHLY,
          period_type: SchwabRb::PriceHistory::PeriodTypes::YEAR,
          period: SchwabRb::PriceHistory::Periods::TWENTY_YEARS
        }
      }.freeze

      module_function

      def resolve(client:, symbol:, start_date:, end_date:, directory:, frequency:, format:, need_extended_hours_data:, need_previous_close:, period_type: nil, period: nil)
        config = FREQUENCY_ALIASES.fetch(frequency)
        path = canonical_output_path(directory: directory, symbol: symbol, frequency: frequency, format: format)
        existing_response = load_cached_price_history(path, format)
        response = existing_response

        unless cached_range_covers?(existing_response, start_date, end_date, frequency)
          FileUtils.mkdir_p(directory)
          downloaded = client.get_price_history(
            api_symbol(symbol),
            period_type: period_type || config.fetch(:period_type),
            period: period || config.fetch(:period),
            frequency_type: config.fetch(:frequency_type),
            frequency: config.fetch(:frequency),
            start_datetime: start_date,
            end_datetime: end_date,
            need_extended_hours_data: need_extended_hours_data,
            need_previous_close: need_previous_close,
            return_data_objects: false
          )
          response = merge_price_history_responses(response, downloaded, symbol)
        end

        File.write(path, serialized_payload(response, format))
        [response, path]
      end

      def canonical_output_path(directory:, symbol:, frequency:, format:)
        File.join(directory, "#{sanitize_symbol(symbol)}_#{frequency}.#{format}")
      end

      def sanitize_symbol(symbol)
        sanitized_symbol = symbol.to_s.gsub(/[^a-zA-Z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
        sanitized_symbol.empty? ? "symbol" : sanitized_symbol
      end

      def api_symbol(symbol)
        raw_symbol = symbol.to_s.strip
        return raw_symbol if raw_symbol.start_with?("$", "/")
        return "$#{raw_symbol}" if INDEX_API_SYMBOLS.include?(raw_symbol.upcase)

        raw_symbol
      end

      def serialized_payload(response, format)
        case format
        when "json"
          JSON.pretty_generate(response)
        when "csv"
          CSV.generate do |csv|
            csv << %w[datetime open high low close volume]
            Array(response[:candles]).each do |candle|
              csv << [
                Time.at(candle.fetch(:datetime) / 1000.0).utc.iso8601,
                candle[:open],
                candle[:high],
                candle[:low],
                candle[:close],
                candle[:volume]
              ]
            end
          end
        else
          raise ArgumentError, "Unsupported format `#{format}`."
        end
      end

      def load_cached_price_history(path, format)
        return unless File.exist?(path)

        parse_price_history_file(path, format)
      end

      def parse_price_history_file(path, format)
        case format
        when "json"
          symbolize_price_history_payload(JSON.parse(File.read(path)))
        when "csv"
          parse_price_history_csv(path)
        else
          raise ArgumentError, "Unsupported format `#{format}`."
        end
      rescue JSON::ParserError => e
        raise ArgumentError, "Unable to parse cached price history at #{path}: #{e.message}"
      end

      def parse_price_history_csv(path)
        candles = CSV.read(path, headers: true).map do |row|
          {
            datetime: Time.iso8601(row.fetch("datetime")).to_i * 1000,
            open: row.fetch("open").to_f,
            high: row.fetch("high").to_f,
            low: row.fetch("low").to_f,
            close: row.fetch("close").to_f,
            volume: row.fetch("volume").to_i
          }
        end

        {
          symbol: File.basename(path).split("_").first,
          empty: candles.empty?,
          candles: candles
        }
      end

      def symbolize_price_history_payload(payload)
        {
          symbol: payload["symbol"] || payload[:symbol],
          empty: payload["empty"].nil? ? payload[:empty] : payload["empty"],
          candles: Array(payload["candles"] || payload[:candles]).map do |candle|
            candle.transform_keys(&:to_sym)
          end
        }
      end

      def cached_range_covers?(response, start_date, end_date, frequency)
        return false unless response

        dates = requested_candle_dates(response, start_date, end_date)
        return false if dates.empty?
        return daily_range_covered?(dates, start_date, end_date) if frequency == "day"

        start_date >= dates.first && end_date <= dates.last
      end

      def candle_dates(response)
        Array(response[:candles]).map do |candle|
          Time.at(candle.fetch(:datetime) / 1000.0).utc.to_date
        end.sort
      end

      def requested_candle_dates(response, start_date, end_date)
        candle_dates(response).select { |date| date >= start_date && date <= end_date }
      end

      def daily_range_covered?(cached_dates, start_date, end_date)
        business_dates_in_range(start_date, end_date).all? { |date| cached_dates.include?(date) }
      end

      def business_dates_in_range(start_date, end_date)
        (start_date..end_date).select { |date| (1..5).cover?(date.wday) }
      end

      def merge_price_history_responses(left, right, fallback_symbol)
        return normalize_price_history_response(right, fallback_symbol) unless left
        return normalize_price_history_response(left, fallback_symbol) unless right

        merged_candles = Array(left[:candles]) + Array(right[:candles])
        deduped_candles = merged_candles.each_with_object({}) do |candle, by_datetime|
          by_datetime[candle.fetch(:datetime)] = candle.transform_keys(&:to_sym)
        end

        {
          symbol: left[:symbol] || right[:symbol] || fallback_symbol,
          empty: deduped_candles.empty?,
          candles: deduped_candles.values.sort_by { |candle| candle.fetch(:datetime) }
        }
      end

      def normalize_price_history_response(response, fallback_symbol)
        {
          symbol: response[:symbol] || fallback_symbol,
          empty: Array(response[:candles]).empty?,
          candles: Array(response[:candles]).map { |candle| candle.transform_keys(&:to_sym) }.sort_by do |candle|
            candle.fetch(:datetime)
          end
        }
      end
    end
  end
end
