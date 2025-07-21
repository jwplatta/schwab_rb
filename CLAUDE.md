# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Setup and Installation
- `bin/setup` - Install dependencies and set up the development environment
- `bundle install` - Install gem dependencies
- `bin/console` - Start an interactive Ruby console with the gem loaded

### Testing
- `bundle exec rake spec` - Run all RSpec tests
- `bundle exec rspec` - Run RSpec tests directly
- `bundle exec rspec spec/path/to/specific_spec.rb` - Run a specific test file
- `bundle exec rspec spec/path/to/specific_spec.rb:line_number` - Run a specific test

### Linting and Code Quality
- `bundle exec rubocop` - Run RuboCop linter
- `bundle exec rubocop -a` - Auto-correct RuboCop violations where possible
- `bundle exec rake` - Run both tests and linting (default task)

### Gem Management
- `bundle exec rake build` - Build the gem
- `bundle exec rake install` - Install the gem locally
- `bundle exec rake release` - Release a new version (creates git tag and pushes to RubyGems)

## Architecture Overview

### Core Structure
This is a Ruby gem (`schwab_rb`) that provides a client library for the Charles Schwab API. The architecture follows a modular design:

**Authentication Layer** (`lib/schwab_rb/auth/`):
- `init_client_easy.rb` - Recommended initialization method that handles token management automatically
- `init_client_login.rb` - Interactive browser-based authentication flow
- `init_client_token_file.rb` - Initialize from existing token file
- `token_manager.rb` - Handles token refresh and persistence
- `login_flow_server.rb` - Temporary server for OAuth callback handling

**Client Layer** (`lib/schwab_rb/clients/`):
- `client.rb` - Synchronous HTTP client for API calls
- `async_client.rb` - Asynchronous client using the `async` gem
- `base_client.rb` - Shared client functionality

**Data Objects** (`lib/schwab_rb/data_objects/`):
- Structured Ruby objects for API responses (Account, Quote, Order, etc.)
- Replaces raw JSON responses with typed objects for better developer experience
- All API methods support `return_data_objects: false` to get raw JSON if needed

**Order Management** (`lib/schwab_rb/orders/`):
- `builder.rb` - Fluent interface for constructing complex orders
- Various enum classes for order parameters (duration, session, instructions, etc.)

### Key Design Patterns

**Three-Tier Client Initialization**:
1. `init_client_easy()` - Handles everything automatically (recommended)
2. `init_client_token_file()` - For existing tokens
3. `init_client_login()` - For interactive authentication

**Data Object Strategy**:
- All API methods return structured Ruby objects by default
- Use `return_data_objects: false` for raw JSON responses
- Data objects are built from JSON using factory patterns

**Async Support**:
- Both sync and async clients available
- Async operations use the `async` gem with promises
- Set `asyncio: true` during client initialization

### Configuration

Environment variables (loaded via `dotenv`):
- `SCHWAB_API_KEY` - Your Schwab API key
- `SCHWAB_APP_SECRET` - Your Schwab application secret  
- `APP_CALLBACK_URL` - OAuth callback URL
- `TOKEN_PATH` - Path for token storage
- `SCHWAB_ACCOUNT_NUMBER` - Your account number
- `SCHWAB_LOGFILE` - Log file path (optional, defaults to STDOUT)
- `SCHWAB_LOG_LEVEL` - Log level (DEBUG, INFO, WARN, ERROR, FATAL)
- `SCHWAB_SILENCE_OUTPUT` - Set to 'true' to disable logging

Programmatic configuration:
```ruby
SchwabRb.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.log_level = 'INFO'
  config.silence_output = false
end
```

### Testing Infrastructure

**Fixtures and Factories**:
- JSON fixtures in `spec/fixtures/` for realistic API responses
- Factory classes in `spec/factories/` for creating test objects
- Extensive mocking of HTTP responses for unit tests

**Test Organization**:
- Unit tests mirror the `lib/` structure
- Separate specs for data objects, clients, auth, and orders
- Uses `async-rspec` for testing async functionality

### Key Dependencies
- `oauth2` - OAuth2 authentication
- `async` + `async-http` - Asynchronous HTTP operations
- `sinatra` + `puma` - Temporary server for OAuth callbacks
- `dotenv` - Environment variable management
- `rspec` + `async-rspec` - Testing framework
- `rubocop` - Code linting

## Common Patterns

### Client Initialization
Always use `init_client_easy()` for new development:
```ruby
client = SchwabRb::Auth.init_client_easy(
  ENV['SCHWAB_API_KEY'],
  ENV['SCHWAB_APP_SECRET'], 
  ENV['APP_CALLBACK_URL'],
  ENV['TOKEN_PATH']
)
```

### Order Building
Use the fluent builder pattern for complex orders:
```ruby
order = SchwabRb::Orders::Builder.new
  .set_session(:normal)
  .set_duration(:day)
  .set_order_type(:market)
  .add_equity_leg(:buy, 'AAPL', 100)
  .build
```

### Error Handling
Token expiration is handled automatically by `init_client_easy()`. Custom error classes are defined in `lib/schwab_rb/orders/errors.rb`.