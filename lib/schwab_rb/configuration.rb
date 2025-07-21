module SchwabRb
  class Configuration
    attr_accessor :logger, :log_file, :log_level, :silence_output

    def initialize
      @logger = nil
      @log_file = ENV.fetch("SCHWAB_LOGFILE", nil)
      @log_level = ENV.fetch("SCHWAB_LOG_LEVEL", "WARN").upcase
      @silence_output = ENV.fetch("SCHWAB_SILENCE_OUTPUT", "false").downcase == "true"
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
