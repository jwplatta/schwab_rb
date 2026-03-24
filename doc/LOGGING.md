# Logging Configuration

The `schwab_rb` gem provides flexible logging configuration options to suit different development and production needs.

## Overview

The gem's logging system is built around two main components:
- `SchwabRb::Configuration` - Manages configuration settings
- `SchwabRb::Logger` - Creates and manages the logger instance

## Configuration Methods

### 1. Environment Variables

Set logging behavior using environment variables:

```bash
export SCHWAB_LOGFILE="/path/to/logfile.log"  # File path or "STDOUT"
export SCHWAB_LOG_LEVEL="INFO"               # DEBUG, INFO, WARN, ERROR, FATAL
```

### 2. Programmatic Configuration

Configure logging in your Ruby code:

```ruby
SchwabRb.configure do |config|
  config.log_file = "/path/to/logfile.log"
  config.log_level = "DEBUG"
  config.silence_output = false
end
```

## Using the Gem's Built-in Logger

### Default Behavior
By default, the gem creates its own logger that:
- Logs to STDOUT
- Uses WARN level
- Rotates log files weekly (when logging to file)
- Uses custom formatting: `[HH:MM:SS] SCHWAB_RB LEVEL: message`

### Example Configuration
```ruby
SchwabRb.configure do |config|
  config.log_file = "/var/log/schwab_rb.log"
  config.log_level = "INFO"
end
```

## Using an External Logger

You can provide your own logger instance instead of using the gem's built-in logger:

### Rails Logger Example
```ruby
# In Rails application
SchwabRb.configure do |config|
  config.logger = Rails.logger
end
```

### Custom Logger Example
```ruby
# Custom logger with specific formatting
my_logger = Logger.new(STDOUT)
my_logger.level = Logger::DEBUG
my_logger.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime} [SCHWAB] #{severity}: #{msg}\n"
end

SchwabRb.configure do |config|
  config.logger = my_logger
end
```

### Structured Logging Example
```ruby
# Using a structured logging library
require 'semantic_logger'

SchwabRb.configure do |config|
  config.logger = SemanticLogger['SchwabRb']
end
```

## Logger Behavior

### External Logger Priority
When an external logger is provided via `config.logger`, it takes precedence over all other settings. The gem will:
- Use your logger instance directly
- Ignore `log_file` and `log_level` settings
- Not apply custom formatting

### Silence Output
Setting `silence_output = true` creates a null logger that discards all messages:

```ruby
SchwabRb.configure do |config|
  config.silence_output = true
end
```

### Log File Handling
When logging to a file, the gem:
- Creates the directory if it doesn't exist
- Creates the log file if it doesn't exist
- Rotates logs weekly
- Returns a null logger if the path is `:null` or `"/dev/null"`

## Log Levels

Available log levels (case-insensitive):
- `DEBUG` - Detailed information for debugging
- `INFO` - General information messages
- `WARN` - Warning messages (default)
- `ERROR` - Error conditions
- `FATAL` - Critical errors

## Accessing the Logger

Get the configured logger instance:

```ruby
logger = SchwabRb::Logger.logger
logger.info("Custom log message")
```

## Configuration Reset

Reset the logger and configuration:

```ruby
# Reset configuration to defaults
SchwabRb.reset_configuration!

# Reset logger instance (forces recreation)
SchwabRb::Logger.reset!
```

Note: The logger is automatically reset when configuration changes are made via `SchwabRb.configure`.