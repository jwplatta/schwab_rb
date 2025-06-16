require 'logger'
require_relative '../../lib/schwab_rb/utils/logger'

fdescribe SchwabRb::Logger do
  let(:log_file) { 'tmp/test.log' }

  before do
    SchwabRb::Logger.instance_variable_set(:@logger, nil)
    ENV['SCHWAB_LOGFILE'] = log_file
    ENV['LOG_LEVEL'] = 'DEBUG'
  end

  after do
    File.delete(log_file) if File.exist?(log_file)
  end

  it 'creates a logger instance' do
    logger = SchwabRb::Logger.logger
    expect(logger).to be_a(::Logger)
  end

  it 'writes logs to the specified file' do
    logger = SchwabRb::Logger.logger
    logger.info('Test log message')

    log_content = File.read(log_file)
    expect(log_content).to include('Test log message')
  end

  it 'respects the log level from the environment variable' do
    logger = SchwabRb::Logger.logger
    expect(logger.level).to eq(::Logger::DEBUG)
  end

  it 'defaults to WARN level if LOG_LEVEL is not set' do
    ENV.delete('LOG_LEVEL')
    logger = SchwabRb::Logger.logger
    expect(logger.level).to eq(::Logger::WARN)
  end

  it 'defaults to STDOUT if SCHWAB_LOGFILE is not set' do
    ENV.delete('SCHWAB_LOGFILE')
    expect { SchwabRb::Logger.logger.info('Test STDOUT log') }.not_to raise_error
  end
end