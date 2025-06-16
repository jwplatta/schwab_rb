require 'logger'
require 'fileutils'

module SchwabRb
  class Logger
    class << self
      def logger
        @logger ||= create_logger
      end

      def configure
        yield(self) if block_given?
      end

      private

      def create_logger
        log_file = ENV.fetch('SCHWAB_LOGFILE', STDOUT)
        log_level = ENV.fetch('LOG_LEVEL', 'WARN').upcase

        if log_file.is_a?(String)
          if File.directory?(File.dirname(log_file)) || !File.exist?(File.dirname(log_file))
            FileUtils.mkdir_p(File.dirname(log_file))
          end

          FileUtils.touch(log_file) unless File.exist?(log_file)
        end

        ::Logger.new(log_file, 'weekly').tap do |log|
          log.level = parse_log_level(log_level)
        end
      end

      def parse_log_level(level)
        case level
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