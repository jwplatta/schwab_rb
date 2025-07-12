require 'logger'
require 'fileutils'

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

        # Use external logger if provided
        return config.logger if config.has_external_logger?

        # Return null logger if silenced
        return null_logger if config.silence_output

        # Create logger if should create one
        return null_logger unless config.should_create_logger?

        # Determine log destination
        log_destination = config.effective_log_file || STDOUT

        # Handle special cases
        if log_destination == :null || log_destination == '/dev/null'
          return null_logger
        end

        # Setup file if it's a file path
        if log_destination.is_a?(String) && log_destination != 'STDOUT'
          setup_log_file(log_destination)
        end

        ::Logger.new(log_destination, 'weekly').tap do |log|
          log.level = parse_log_level(config.log_level)
          log.formatter = proc do |severity, datetime, progname, msg|
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
        when 'DEBUG' then ::Logger::DEBUG
        when 'INFO' then ::Logger::INFO
        when 'WARN' then ::Logger::WARN
        when 'ERROR' then ::Logger::ERROR
        when 'FATAL' then ::Logger::FATAL
        else ::Logger::WARN
        end
      end
    end
  end
end