require "logger"
require "fileutils"

module SchwabRb
  class Logger
    class << self
      def logger
        @logger ||= create_logger
      end

      def reset!
        @logger = nil
      end

      def configure
        yield(self) if block_given?
      end

      private

      def create_logger
        config = SchwabRb.configuration

        return config.logger if config.has_external_logger?
        return null_logger if config.silence_output
        return null_logger unless config.should_create_logger?

        log_destination = config.effective_log_file || STDOUT

        return null_logger if [:null, "/dev/null"].include?(log_destination)

        setup_log_file(log_destination) if log_destination.is_a?(String) && log_destination != "STDOUT"

        ::Logger.new(log_destination, "weekly").tap do |log|
          log.level = parse_log_level(config.log_level)
          log.formatter = proc do |severity, datetime, _progname, msg|
            "[#{datetime.strftime('%H:%M:%S')}] SCHWAB_RB #{severity}: #{msg}\n"
          end
        end
      end

      def setup_log_file(log_file)
        dir = File.dirname(log_file)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        FileUtils.touch(log_file) unless File.exist?(log_file)
      end

      def null_logger
        ::Logger.new(IO::NULL).tap do |log|
          log.level = ::Logger::FATAL
        end
      end

      def parse_log_level(level)
        case level.to_s.upcase
        when "DEBUG" then ::Logger::DEBUG
        when "INFO" then ::Logger::INFO
        when "WARN" then ::Logger::WARN
        when "ERROR" then ::Logger::ERROR
        when "FATAL" then ::Logger::FATAL
        else ::Logger::WARN
        end
      end
    end
  end
end
