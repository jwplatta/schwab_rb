# frozen_string_literal: true

require "csv"
require "date"
require "json"
require "optparse"
require "pathname"
require "fileutils"
require "time"

module SchwabRb
  module CLI
    class Error < StandardError; end

    # Minimal command dispatcher for the gem's built-in CLI.
    # rubocop:disable Metrics/ClassLength
    class App
      DEFAULT_HISTORY_DIR = "~/.schwab_rb/data/history"
      DEFAULT_OPTIONS_DIR = "~/.schwab_rb/data/options"
      INDEX_API_SYMBOLS = %w[
        COMPX DJX MID NDX OEX RUT SPX VIX VIX9D VIX1D XSP
      ].freeze
      SUPPORTED_FORMATS = %w[csv json].freeze
      OPTION_SAMPLE_CSV_HEADERS = %w[
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
      PERIOD_TYPES = {
        "day" => SchwabRb::PriceHistory::PeriodTypes::DAY,
        "month" => SchwabRb::PriceHistory::PeriodTypes::MONTH,
        "year" => SchwabRb::PriceHistory::PeriodTypes::YEAR,
        "ytd" => SchwabRb::PriceHistory::PeriodTypes::YEAR_TO_DATE
      }.freeze
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

      def initialize(env: ENV, stdout: $stdout, stderr: $stderr)
        @env = env
        @stdout = stdout
        @stderr = stderr
      end

      def call(argv)
        command = argv.shift

        case command
        when nil, "help", "--help", "-h"
          handle_help(argv)
        when "login"
          handle_login(argv)
        when "price-history"
          handle_price_history(argv)
        when "sample"
          handle_option_sample(argv)
        else
          print_error("Unknown command `#{command}`.\n\n#{root_help}")
          1
        end
      rescue OptionParser::ParseError, ArgumentError, Error => e
        print_error(e.message)
        1
      end

      private

      attr_reader :env, :stdout, :stderr

      def handle_help(argv)
        topic = argv.first

        case topic
        when nil
          stdout.puts(root_help)
        when "login"
          stdout.puts(login_help)
        when "price-history"
          stdout.puts(price_history_help)
        when "sample"
          stdout.puts(option_sample_help)
        else
          raise Error, "Unknown help topic `#{topic}`."
        end

        0
      end

      # rubocop:disable Metrics/AbcSize
      def handle_login(argv)
        parser = OptionParser.new do |opts|
          opts.banner = login_help
        end

        parser.parse!(argv)
        raise Error, "Unexpected arguments: #{argv.join(' ')}" if argv.any?

        credentials = load_credentials(require_callback_url: true)
        token_path = resolved_token_path

        SchwabRb::Auth.init_client_login(
          credentials.fetch(:api_key),
          credentials.fetch(:app_secret),
          credentials.fetch(:callback_url),
          token_path
        )

        stdout.puts("Authentication succeeded. Token saved to #{token_path}")
        0
      rescue JSON::ParserError
        raise Error,
              "The token file at #{resolved_token_path} is not valid JSON. " \
              "Delete it or run `schwab_rb login` to recreate it."
      rescue OAuth2::Error, SchwabRb::Auth::RedirectTimeoutError, SchwabRb::Auth::RedirectServerExitedError => e
        raise Error, "Authentication failed: #{e.message}"
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      def handle_price_history(argv)
        options = {
          dir: default_history_dir,
          end_date: Date.today,
          format: "json",
          freq: "day",
          need_extended_hours_data: false,
          need_previous_close: false
        }

        # rubocop:disable Metrics/BlockLength
        parser = OptionParser.new do |opts|
          opts.banner = price_history_help
          opts.on("-s", "--symbol SYMBOL", "Ticker symbol to download") { |value| options[:symbol] = value }
          opts.on("--dir DIRECTORY", "Output directory (default: #{DEFAULT_HISTORY_DIR})") do |value|
            options[:dir] = value
          end
          opts.on("--start-date DATE", "Start date in YYYY-MM-DD format") do |value|
            options[:start_date] = parse_date(value, "start-date")
          end
          opts.on("--end-date DATE", "End date in YYYY-MM-DD format") do |value|
            options[:end_date] = parse_date(value, "end-date")
          end
          opts.on("-p", "--period PERIOD", Integer, "Period value passed through to the API") do |value|
            options[:period] = value
          end
          opts.on("--period-type TYPE", "Period type: #{PERIOD_TYPES.keys.join(', ')}") do |value|
            options[:period_type] = normalize_period_type(value)
          end
          opts.on("--freq FREQ", "Frequency: #{FREQUENCY_ALIASES.keys.join(', ')}") do |value|
            options[:freq] = normalize_frequency(value)
          end
          opts.on("--[no-]need-extended-hours-data", "Include extended hours data") do |value|
            options[:need_extended_hours_data] = value
          end
          opts.on("--[no-]need-previous-close", "Include previous close data") do |value|
            options[:need_previous_close] = value
          end
          opts.on("--format FORMAT", "Output format: #{SUPPORTED_FORMATS.join(', ')}") do |value|
            options[:format] = normalize_format(value)
          end
        end
        # rubocop:enable Metrics/BlockLength

        parser.parse!(argv)
        raise Error, "Unexpected arguments: #{argv.join(' ')}" if argv.any?

        options[:end_date] = normalized_end_date(options.fetch(:end_date))
        validate_price_history_options!(options)

        _, output_path = resolve_price_history_response(options)

        stdout.puts("Saved #{options[:symbol]} price history to #{output_path}")
        0
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      def handle_option_sample(argv)
        options = {
          dir: default_options_dir,
          format: "csv",
          timestamp: Time.now
        }

        parser = OptionParser.new do |opts|
          opts.banner = option_sample_help
          opts.on("-s", "--symbol SYMBOL", "Ticker symbol to sample") { |value| options[:symbol] = value }
          opts.on("--root ROOT", "Option root to filter and use in the output filename") do |value|
            options[:root] = value
          end
          opts.on("--expiration-date DATE", "Expiration date in YYYY-MM-DD format") do |value|
            options[:expiration_date] = parse_date(value, "expiration-date")
          end
          opts.on("--dir DIRECTORY", "Output directory (default: #{DEFAULT_OPTIONS_DIR})") do |value|
            options[:dir] = value
          end
          opts.on("--format FORMAT", "Output format: #{SUPPORTED_FORMATS.join(', ')}") do |value|
            options[:format] = normalize_format(value)
          end
        end

        parser.parse!(argv)
        raise Error, "Unexpected arguments: #{argv.join(' ')}" if argv.any?

        validate_option_sample_options!(options)

        output_path = resolve_option_sample_response(options)

        stdout.puts("Saved #{options[:symbol]} option sample to #{output_path}")
        0
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      def resolve_price_history_response(options)
        directory = SchwabRb::PathSupport.expand_path(options.fetch(:dir))

        existing_response = load_cached_price_history(directory, options)
        response = existing_response

        unless cached_range_covers?(
          existing_response,
          options.fetch(:start_date),
          options.fetch(:end_date),
          options.fetch(:freq)
        )
          client = build_non_interactive_client
          FileUtils.mkdir_p(directory)
          downloaded = fetch_price_history_range(
            client,
            options,
            options.fetch(:start_date),
            options.fetch(:end_date)
          )

          response = merge_price_history_responses(response, downloaded, options.fetch(:symbol))
        end

        output_path = canonical_output_path(directory, options)
        write_payload(output_path, response, options.fetch(:format))
        [response, output_path]
      end
      # rubocop:enable Metrics/AbcSize

      def write_payload(output_path, response, format)
        File.write(output_path, serialized_payload(response, format))
      end

      def resolve_option_sample_response(options)
        directory = SchwabRb::PathSupport.expand_path(options.fetch(:dir))
        response = fetch_option_sample(build_non_interactive_client, options)
        FileUtils.mkdir_p(directory)
        output_path = option_sample_output_path(directory, options, response)
        write_option_sample(output_path, response, options)
        output_path
      end

      def write_option_sample(output_path, response, options)
        File.write(output_path, serialized_option_sample(response, options))
      end

      # rubocop:disable Metrics/AbcSize
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
          raise Error, "Unsupported format `#{format}`."
        end
      end
      # rubocop:enable Metrics/AbcSize

      def serialized_option_sample(response, options)
        case options.fetch(:format)
        when "json"
          JSON.pretty_generate(response)
        when "csv"
          serialized_option_sample_csv(response, options)
        else
          raise Error, "Unsupported format `#{options[:format]}`."
        end
      end

      def serialized_option_sample_csv(response, options)
        sample_timestamp = options.fetch(:timestamp).utc.iso8601

        CSV.generate do |csv|
          csv << OPTION_SAMPLE_CSV_HEADERS
          option_sample_rows(response).each do |option|
            csv << option_sample_csv_row(response, option, sample_timestamp)
          end
        end
      end

      # rubocop:disable Metrics/AbcSize
      def option_sample_csv_row(response, option, _sample_timestamp)
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

      def load_cached_price_history(directory, options)
        path = canonical_output_path(directory, options)
        return unless File.exist?(path)

        parse_price_history_file(path, options.fetch(:format))
      end

      def parse_price_history_file(path, format)
        case format
        when "json"
          symbolize_price_history_payload(JSON.parse(File.read(path)))
        when "csv"
          parse_price_history_csv(path)
        else
          raise Error, "Unsupported format `#{format}`."
        end
      rescue JSON::ParserError => e
        raise Error, "Unable to parse cached price history at #{path}: #{e.message}"
      end

      # rubocop:disable Metrics/AbcSize
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
      # rubocop:enable Metrics/AbcSize

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

      def fetch_price_history_range(client, options, start_date, end_date)
        frequency_config = FREQUENCY_ALIASES.fetch(options[:freq])
        client.get_price_history(
          api_symbol(options.fetch(:symbol)),
          period_type: options[:period_type] || frequency_config.fetch(:period_type),
          period: options[:period] || frequency_config.fetch(:period),
          frequency_type: frequency_config.fetch(:frequency_type),
          frequency: frequency_config.fetch(:frequency),
          start_datetime: start_date,
          end_datetime: end_date,
          need_extended_hours_data: options.fetch(:need_extended_hours_data),
          need_previous_close: options.fetch(:need_previous_close),
          return_data_objects: false
        )
      end

      def fetch_option_sample(client, options)
        expiration_date = options.fetch(:expiration_date)

        response = client.get_option_chain(
          api_symbol(options.fetch(:symbol)),
          contract_type: SchwabRb::Option::ContractTypes::ALL,
          strike_range: SchwabRb::Option::StrikeRanges::ALL,
          from_date: expiration_date,
          to_date: expiration_date,
          return_data_objects: false
        )

        filter_option_sample_response(response, options[:root])
      end

      def option_sample_rows(response)
        rows = [response[:callExpDateMap], response[:putExpDateMap]].compact.flat_map do |date_map|
          option_rows_from_date_map(date_map)
        end

        rows.sort_by do |option|
          [
            normalize_option_date(option[:expirationDate]).to_s,
            option[:putCall].to_s,
            option[:strikePrice].to_f
          ]
        end
      end

      def option_rows_from_date_map(date_map)
        date_map.values.flat_map do |strikes|
          strikes.values.flatten.map { |option| option.transform_keys(&:to_sym) }
        end
      end

      def filter_option_sample_response(response, option_root)
        return response if blank?(option_root)

        normalized_root = option_root.to_s.strip.upcase
        filtered_call_map = filter_option_date_map_by_root(response[:callExpDateMap], normalized_root)
        filtered_put_map = filter_option_date_map_by_root(response[:putExpDateMap], normalized_root)

        response.merge(
          callExpDateMap: filtered_call_map,
          putExpDateMap: filtered_put_map
        )
      end

      def filter_option_date_map_by_root(date_map, option_root)
        return {} unless date_map

        date_map.each_with_object({}) do |(expiration_key, strikes), filtered_dates|
          filtered_strikes = strikes.each_with_object({}) do |(strike, contracts), filtered_by_strike|
            matching_contracts = contracts.select { |contract| contract[:optionRoot].to_s.upcase == option_root }
            filtered_by_strike[strike] = matching_contracts if matching_contracts.any?
          end

          filtered_dates[expiration_key] = filtered_strikes if filtered_strikes.any?
        end
      end

      def normalize_option_date(value)
        return if value.nil?

        Date.parse(value.to_s).iso8601
      end

      def normalize_option_timestamp(value)
        return if value.nil?

        Time.at(value / 1000.0).utc.iso8601
      end

      def api_symbol(symbol)
        raw_symbol = symbol.to_s.strip
        return raw_symbol if raw_symbol.start_with?("$", "/")

        return "$#{raw_symbol}" if INDEX_API_SYMBOLS.include?(raw_symbol.upcase)

        raw_symbol
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
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
          candles: deduped_candles
            .values
            .sort_by { |candle| candle.fetch(:datetime) }
        }
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

      def normalize_price_history_response(response, fallback_symbol)
        {
          symbol: response[:symbol] || fallback_symbol,
          empty: Array(response[:candles]).empty?,
          candles: Array(response[:candles]).map { |candle| candle.transform_keys(&:to_sym) }.sort_by do |candle|
            candle.fetch(:datetime)
          end
        }
      end

      def build_non_interactive_client
        credentials = load_credentials(require_callback_url: false)
        token_path = resolved_token_path

        client = SchwabRb::Auth.init_client_token_file(
          credentials.fetch(:api_key),
          credentials.fetch(:app_secret),
          token_path
        )
        client.refresh!

        return client unless client.session.expired?

        raise Error, "No valid API token found at #{token_path}. Run `schwab_rb login` to authenticate."
      rescue Errno::ENOENT
        raise Error, "No valid API token found at #{token_path}. Run `schwab_rb login` to authenticate."
      rescue JSON::ParserError
        raise Error, "The token file at #{token_path} is not valid JSON. Run `schwab_rb login` to recreate it."
      rescue OAuth2::Error => e
        raise Error, "Unable to use the token at #{token_path}: #{e.message}. Run `schwab_rb login` to refresh it."
      end

      # rubocop:disable Metrics/AbcSize
      def load_credentials(require_callback_url:)
        api_key = env["SCHWAB_API_KEY"]
        app_secret = env["SCHWAB_APP_SECRET"]
        callback_url = env["SCHWAB_APP_CALLBACK_URL"] || env["APP_CALLBACK_URL"]

        missing = []
        missing << "SCHWAB_API_KEY" if blank?(api_key)
        missing << "SCHWAB_APP_SECRET" if blank?(app_secret)
        missing << "SCHWAB_APP_CALLBACK_URL" if require_callback_url && blank?(callback_url)

        return { api_key: api_key, app_secret: app_secret, callback_url: callback_url } if missing.empty?

        raise Error, "Missing required environment variables: #{missing.join(', ')}"
      end
      # rubocop:enable Metrics/AbcSize

      def validate_price_history_options!(options)
        raise Error, "The `--symbol` option is required." if blank?(options[:symbol])
        raise Error, "The `--start-date` option is required." unless options[:start_date]
        return unless options[:end_date] < options[:start_date]

        raise Error, "`--end-date` must be on or after `--start-date`."
      end

      def validate_option_sample_options!(options)
        raise Error, "The `--symbol` option is required." if blank?(options[:symbol])
        raise Error, "The `--expiration-date` option is required." unless options[:expiration_date]
      end

      def resolved_token_path
        token_path = env["SCHWAB_TOKEN_PATH"] || env["TOKEN_PATH"] || SchwabRb::Constants::DEFAULT_TOKEN_PATH
        SchwabRb::PathSupport.expand_path(token_path)
      end

      def default_history_dir
        SchwabRb::PathSupport.expand_path(DEFAULT_HISTORY_DIR)
      end

      def default_options_dir
        SchwabRb::PathSupport.expand_path(DEFAULT_OPTIONS_DIR)
      end

      def normalize_format(value)
        format = value.to_s.downcase
        return format if SUPPORTED_FORMATS.include?(format)

        raise Error, "Unsupported format `#{value}`. Use one of: #{SUPPORTED_FORMATS.join(', ')}"
      end

      def normalize_frequency(value)
        normalized = value.to_s.downcase.delete(" ")
        return normalized if FREQUENCY_ALIASES.key?(normalized)

        raise Error, "Unsupported frequency `#{value}`. Use one of: #{FREQUENCY_ALIASES.keys.join(', ')}"
      end

      def normalize_period_type(value)
        normalized = value.to_s.downcase
        return PERIOD_TYPES.fetch(normalized) if PERIOD_TYPES.key?(normalized)

        raise Error, "Unsupported period type `#{value}`. Use one of: #{PERIOD_TYPES.keys.join(', ')}"
      end

      def parse_date(value, option_name)
        Date.iso8601(value)
      rescue Date::Error
        raise Error, "Invalid #{option_name} `#{value}`. Use YYYY-MM-DD."
      end

      def normalized_end_date(end_date)
        return end_date unless end_date == Date.today

        end_date - 1
      end

      def canonical_output_path(directory, options)
        File.join(
          directory,
          "#{sanitize_symbol(options.fetch(:symbol))}_#{options.fetch(:freq)}.#{options.fetch(:format)}"
        )
      end

      def option_sample_output_path(directory, options, response)
        File.join(
          directory,
          [
            sanitize_symbol(options[:root] || option_sample_root(response, options.fetch(:symbol))),
            "exp#{options.fetch(:expiration_date).iso8601}",
            options.fetch(:timestamp).strftime("%Y-%m-%d_%H-%M-%S")
          ].join("_") + ".#{options.fetch(:format)}"
        )
      end

      def option_sample_root(response, fallback_symbol)
        first_option = option_sample_rows(response).find { |option| !blank?(option[:optionRoot]) }
        first_option ? first_option[:optionRoot] : fallback_symbol
      end

      def sanitize_symbol(symbol)
        sanitized_symbol = symbol.to_s.gsub(/[^a-zA-Z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
        sanitized_symbol = "symbol" if sanitized_symbol.empty?
        sanitized_symbol
      end

      def blank?(value)
        value.nil? || value.to_s.strip.empty?
      end

      def print_error(message)
        stderr.puts(message)
      end

      def root_help
        <<~HELP
          Usage: schwab_rb COMMAND [options]

          Commands:
            help [command]   Show general or command-specific help
            login            Authenticate and store a shared Schwab token
            price-history    Download price history data to disk
            sample           Download an option-chain sample for one expiration
        HELP
      end

      def login_help
        <<~HELP
          Usage: schwab_rb login

          Authenticates with Schwab in a browser and stores the token at #{resolved_token_path}.
          Required environment variables: SCHWAB_API_KEY, SCHWAB_APP_SECRET, SCHWAB_APP_CALLBACK_URL
        HELP
      end

      def price_history_help
        <<~HELP
          Usage: schwab_rb price-history --symbol SYMBOL --start-date YYYY-MM-DD [options]

          Options:
            -s, --symbol SYMBOL                    Ticker symbol to download
                --dir DIRECTORY                    Output directory (default: #{DEFAULT_HISTORY_DIR})
                --start-date DATE                 Start date in YYYY-MM-DD format
                --end-date DATE                   End date in YYYY-MM-DD format (default: today)
            -p, --period PERIOD                   Period value passed through to the API
                --period-type TYPE                Period type: #{PERIOD_TYPES.keys.join(', ')}
                --freq FREQ                       Frequency: #{FREQUENCY_ALIASES.keys.join(', ')} (default: day)
                --[no-]need-extended-hours-data  Include extended hours data (default: false)
                --[no-]need-previous-close       Include previous close data (default: false)
                --format FORMAT                  Output format: #{SUPPORTED_FORMATS.join(', ')} (default: json)
        HELP
      end

      def option_sample_help
        <<~HELP
          Usage: schwab_rb sample --symbol SYMBOL --expiration-date YYYY-MM-DD [options]

          Downloads the full option chain for a single expiration and writes a timestamped sample file.

          Options:
            -s, --symbol SYMBOL          Underlying symbol to sample
                --root ROOT              Option root to filter and use in the output filename
                --expiration-date DATE   Expiration date in YYYY-MM-DD format
                --dir DIRECTORY          Output directory (default: #{DEFAULT_OPTIONS_DIR})
                --format FORMAT          Output format: #{SUPPORTED_FORMATS.join(', ')} (default: csv)
        HELP
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
