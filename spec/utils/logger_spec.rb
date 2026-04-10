# frozen_string_literal: true

require "logger"
require "fileutils"
require_relative "../../lib/schwab_rb"

describe SchwabRb::Logger do
  let(:schwab_home) { File.expand_path("tmp/schwab_home") }
  let(:log_file) { File.join(schwab_home, "custom.log") }
  let(:default_log_file) { File.join(schwab_home, "schwab_rb.log") }

  before do
    FileUtils.mkdir_p("tmp")
    FileUtils.rm_rf(schwab_home)
    ENV["SCHWAB_LOGFILE"] = log_file
    ENV["SCHWAB_LOG_LEVEL"] = "DEBUG"
    ENV["SCHWAB_HOME"] = schwab_home
    SchwabRb.reset_configuration! # Reset configuration AFTER setting env vars
    SchwabRb::Logger.instance_variable_set(:@logger, nil)
  end

  after do
    FileUtils.rm_rf(schwab_home)
    ENV.delete("SCHWAB_LOGFILE")
    ENV.delete("SCHWAB_LOG_LEVEL")
    ENV.delete("SCHWAB_HOME")
    SchwabRb.reset_configuration!
    SchwabRb::Logger.instance_variable_set(:@logger, nil)
  end

  it "creates a logger instance" do
    logger = SchwabRb::Logger.logger
    expect(logger).to be_a(Logger)
  end

  it "writes logs to the specified file" do
    logger = SchwabRb::Logger.logger
    logger.info("Test log message")

    expect(File.exist?(log_file)).to be true

    log_content = File.read(log_file)
    expect(log_content).to include("Test log message")
  end

  it "respects the log level from the environment variable" do
    logger = SchwabRb::Logger.logger
    expect(logger.level).to eq(Logger::DEBUG)
  end

  it "defaults to WARN level if SCHWAB_LOG_LEVEL is not set" do
    ENV.delete("SCHWAB_LOG_LEVEL")
    SchwabRb::Logger.instance_variable_set(:@logger, nil)
    SchwabRb.reset_configuration!
    logger = SchwabRb::Logger.logger
    expect(logger.level).to eq(Logger::WARN)
  end

  it "defaults to a log file under SCHWAB_HOME if SCHWAB_LOGFILE is not set" do
    ENV.delete("SCHWAB_LOGFILE")
    SchwabRb::Logger.instance_variable_set(:@logger, nil)
    SchwabRb.reset_configuration!

    logger = SchwabRb::Logger.logger
    logger.info("Test default log")

    expect(SchwabRb.configuration.effective_log_file).to eq(default_log_file)
    expect(File.exist?(default_log_file)).to be true
    expect(File.read(default_log_file)).to include("Test default log")
  end
end
