require "logger"
require "fileutils"
require_relative "../../lib/schwab_rb"

describe SchwabRb::Logger do
  let(:log_file) { "tmp/test.log" }

  before do
    FileUtils.mkdir_p("tmp") # Ensure tmp directory exists
    ENV["SCHWAB_LOGFILE"] = log_file
    ENV["SCHWAB_LOG_LEVEL"] = "DEBUG"
    SchwabRb.reset_configuration! # Reset configuration AFTER setting env vars
    SchwabRb::Logger.instance_variable_set(:@logger, nil)
  end

  after do
    File.delete(log_file) if File.exist?(log_file)
    ENV.delete("SCHWAB_LOGFILE")
    ENV.delete("SCHWAB_LOG_LEVEL")
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

  it "defaults to STDOUT if SCHWAB_LOGFILE is not set" do
    ENV.delete("SCHWAB_LOGFILE")
    expect { SchwabRb::Logger.logger.info("Test STDOUT log") }.not_to raise_error
  end
end
