# frozen_string_literal: true

require "date"
require "json"
require "optparse"
require "pathname"

module SchwabRb
  module CLI
    class Error < StandardError; end

    # Minimal command dispatcher for the gem's built-in CLI.
    # rubocop:disable Metrics/ClassLength
    class App
      DEFAULT_HISTORY_DIR = "~/.schwab_rb/data/history"
      DEFAULT_OPTIONS_DIR = "~/.schwab_rb/data/options"
      SUPPORTED_FORMATS = %w[csv json].freeze
      PERIOD_TYPES = {
        "day" => SchwabRb::PriceHistory::PeriodTypes::DAY,
        "month" => SchwabRb::PriceHistory::PeriodTypes::MONTH,
        "year" => SchwabRb::PriceHistory::PeriodTypes::YEAR,
        "ytd" => SchwabRb::PriceHistory::PeriodTypes::YEAR_TO_DATE
      }.freeze
      FREQUENCY_ALIASES = SchwabRb::PriceHistory::Downloader::FREQUENCY_ALIASES

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

        _, output_path = resolve_option_sample_response(options)

        stdout.puts("Saved #{options[:symbol]} option sample to #{output_path}")
        0
      end
      # rubocop:enable Metrics/AbcSize

      def resolve_price_history_response(options)
        directory = SchwabRb::PathSupport.expand_path(options.fetch(:dir))
        SchwabRb::PriceHistory::Downloader.resolve(
          client: build_non_interactive_client,
          symbol: options.fetch(:symbol),
          start_date: options.fetch(:start_date),
          end_date: options.fetch(:end_date),
          directory: directory,
          frequency: options.fetch(:freq),
          format: options.fetch(:format),
          need_extended_hours_data: options.fetch(:need_extended_hours_data),
          need_previous_close: options.fetch(:need_previous_close),
          period_type: options[:period_type],
          period: options[:period]
        )
      end

      def resolve_option_sample_response(options)
        directory = SchwabRb::PathSupport.expand_path(options.fetch(:dir))
        SchwabRb::OptionSample::Downloader.resolve(
          client: build_non_interactive_client,
          symbol: options.fetch(:symbol),
          root: options[:root],
          expiration_date: options.fetch(:expiration_date),
          directory: directory,
          format: options.fetch(:format),
          timestamp: options.fetch(:timestamp)
        )
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
        SchwabRb::PriceHistory::Downloader.canonical_output_path(
          directory: directory,
          symbol: options.fetch(:symbol),
          frequency: options.fetch(:freq),
          format: options.fetch(:format)
        )
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
