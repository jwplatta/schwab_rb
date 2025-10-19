# frozen_string_literal: true

module SchwabRb
  class Configuration
    attr_accessor :logger, :log_file, :log_level, :silence_output,
                  :schwab_home, :account_hashes_path, :account_names_path

    def initialize
      @logger = nil
      @log_file = ENV.fetch("SCHWAB_LOGFILE", nil)
      @log_level = ENV.fetch("SCHWAB_LOG_LEVEL", "WARN").upcase
      @silence_output = ENV.fetch("SCHWAB_SILENCE_OUTPUT", "false").downcase == "true"

      default_home = File.expand_path("~/.schwab_rb")
      @schwab_home = ENV.fetch("SCHWAB_HOME", default_home)
      @account_hashes_path = ENV.fetch("SCHWAB_ACCOUNT_HASHES_PATH", File.join(@schwab_home, "account_hashes.json"))
      @account_names_path = ENV.fetch("SCHWAB_ACCOUNT_NAMES_PATH", File.join(@schwab_home, "account_names.json"))
    end

    def has_external_logger?
      !@logger.nil?
    end

    def should_create_logger?
      !has_external_logger? && !@silence_output
    end

    def effective_log_file
      @log_file || (ENV["LOGFILE"] if ENV["LOGFILE"] && !ENV["LOGFILE"].empty?)
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
      SchwabRb::Logger.reset! if defined?(SchwabRb::Logger)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
