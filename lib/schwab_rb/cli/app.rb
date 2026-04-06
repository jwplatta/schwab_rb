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
      DEFAULT_DATA_DIR = "~/.schwab_rb/data"
      SUPPORTED_FORMATS = %w[csv json].freeze
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
          dir: default_data_dir,
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
          opts.on("--dir DIRECTORY", "Output directory (default: #{DEFAULT_DATA_DIR})") do |value|
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

        validate_price_history_options!(options)

        _, output_path = resolve_price_history_response(options)

        stdout.puts("Saved #{options[:symbol]} price history to #{output_path}")
        0
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      def resolve_price_history_response(options)
        directory = SchwabRb::PathSupport.expand_path(options.fetch(:dir))
        FileUtils.mkdir_p(directory)

        existing_response = load_cached_price_history(directory, options)
        response = existing_response

        unless cached_range_covers?(existing_response, options.fetch(:start_date), options.fetch(:end_date))
          client = build_non_interactive_client
          missing_ranges(existing_response, options.fetch(:start_date), options.fetch(:end_date)).each do |range|
            downloaded = fetch_price_history_range(client, options, range.fetch(:start_date), range.fetch(:end_date))
            response = merge_price_history_responses(response, downloaded, options.fetch(:symbol))
          end
        end

        output_path = canonical_output_path(directory, options)
        write_payload(output_path, response, options.fetch(:format))
        [response, output_path]
      end
      # rubocop:enable Metrics/AbcSize

      def write_price_history(response, options)
        directory = SchwabRb::PathSupport.expand_path(options.fetch(:dir))
        FileUtils.mkdir_p(directory)

        filename = build_filename(
          options.fetch(:symbol),
          options.fetch(:freq),
          options.fetch(:start_date),
          options.fetch(:end_date),
          options.fetch(:format)
        )
        output_path = File.join(directory, filename)
        payload = serialized_payload(response, options.fetch(:format))

        File.write(output_path, payload)
        output_path
      end

      def write_payload(output_path, response, format)
        File.write(output_path, serialized_payload(response, format))
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

      def cached_range_covers?(response, start_date, end_date)
        return false unless response

        dates = candle_dates(response)
        return false if dates.empty?

        start_date >= dates.first && end_date <= dates.last
      end

      def missing_ranges(response, start_date, end_date)
        return [{ start_date: start_date, end_date: end_date }] unless response

        dates = candle_dates(response)
        return [{ start_date: start_date, end_date: end_date }] if dates.empty?

        ranges = []
        ranges << { start_date: start_date, end_date: dates.first - 1 } if start_date < dates.first
        ranges << { start_date: dates.last + 1, end_date: end_date } if end_date > dates.last
        ranges
      end

      def candle_dates(response)
        Array(response[:candles]).map do |candle|
          Time.at(candle.fetch(:datetime) / 1000.0).utc.to_date
        end.sort
      end

      def fetch_price_history_range(client, options, start_date, end_date)
        frequency_config = FREQUENCY_ALIASES.fetch(options[:freq])
        client.get_price_history(
          options.fetch(:symbol),
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

      def resolved_token_path
        token_path = env["SCHWAB_TOKEN_PATH"] || env["TOKEN_PATH"] || SchwabRb::Constants::DEFAULT_TOKEN_PATH
        SchwabRb::PathSupport.expand_path(token_path)
      end

      def default_data_dir
        SchwabRb::PathSupport.expand_path(DEFAULT_DATA_DIR)
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

      def build_filename(symbol, frequency, start_date, end_date, format)
        sanitized_symbol = sanitize_symbol(symbol)

        [
          sanitized_symbol,
          frequency,
          start_date.iso8601,
          end_date.iso8601
        ].join("_") + ".#{format}"
      end

      def canonical_output_path(directory, options)
        File.join(
          directory,
          "#{sanitize_symbol(options.fetch(:symbol))}_#{options.fetch(:freq)}.#{options.fetch(:format)}"
        )
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
                --dir DIRECTORY                    Output directory (default: #{DEFAULT_DATA_DIR})
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
    end
    # rubocop:enable Metrics/ClassLength
  end
end
