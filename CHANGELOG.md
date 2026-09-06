## [Unreleased]

## [1.0.0] - 2026-09-05

### Breaking Changes
- **Token storage**: Tokens are now persisted in SQLite (`~/.schwab_rb/schwab.db`) instead of a JSON file. `init_client_easy` and `init_client_login` no longer accept a `token_path` argument. Use `init_client_from_database` instead of `init_client_token_file`.
- **Account management**: `AccountHashManager`, `account_names.json`, and `account_hashes.json` are removed. Set `SCHWAB_ACCOUNT_NUMBER` in your environment instead. Account hashes are fetched from the API automatically and cached in SQLite.
- **Client method signatures**: All account-specific methods (`get_account`, `place_order`, `get_order`, etc.) now use `account_hash:` as a keyword argument instead of a positional argument. The `account_name:` keyword argument is removed.

### Added
- **WebSocket streaming client**: Real-time market data streaming via `SchwabRb::Stream::Client`
  - Event-based API: `stream.on(:nyse_book, symbols: ["AAPL"], fields: :all) { |event| ... }`
  - Supported services: `NYSE_BOOK`, `NASDAQ_BOOK`, `OPTIONS_BOOK`, `LEVELONE_EQUITIES`, `LEVELONE_OPTIONS`, `LEVELONE_FUTURES`, `LEVELONE_FUTURES_OPTIONS`, `LEVELONE_FOREX`, `CHART_EQUITY`, `CHART_FUTURES`, `SCREENER_EQUITY`, `SCREENER_OPTION`, `ACCT_ACTIVITY`
  - Ruby constant field definitions for all services (e.g. `Fields::Book::BIDS`, `Fields::LevelOneEquity::BID_PRICE`)
  - Exponential backoff reconnection (2s initial, doubles, 120s cap)
  - Sync (`Stream::Client`) and async (`Stream::AsyncClient`) wrappers
- **SQLite storage** (`SchwabRb::Storage::Database`): Single database at `~/.schwab_rb/schwab.db` (configurable via `SCHWAB_DATABASE_PATH`) storing tokens and account hashes
- **`SCHWAB_ACCOUNT_NUMBER` env var**: Configure your account number once; the gem auto-fetches and caches the account hash on first use
- **`init_client_from_database`**: New initializer that loads tokens from SQLite (replaces `init_client_token_file`)

### Fixed
- CLI `login` no longer reads from `ARGF` at the browser prompt, which prevented `schwab_rb login` from opening the browser when command arguments were present
- `OptionExpirationChain` now accepts both string-keyed and symbol-keyed hashes, matching `BaseClient#get_option_expiration_chain`

### Changed
- CLI history downloads now default to `~/.schwab_rb/data/history`
- CLI option samples now default to `~/.schwab_rb/data/options`
- CLI `login` success message updated to reflect database storage
- `PathSupport.expand_path` error message generalized from `"token_path is nil or empty"` to `"path is nil or empty"`

## [0.6.0] - 2025-12-11

### Breaking Changes
- **OrderPreview**: Replaced `projected_commission` with `commission_and_fee` structure to match current Schwab API
- **OrderPreview**: Commission/fee data now uses nested `commissionLegs`/`feeLegs` instead of scalar values
- **OrderValidationResult**: Changed from `warningMessage` string to `warns` array of objects with `activity_message` and `original_severity`
- **OrderValidationResult**: Updated `Reject` structure to match `Warn` structure
- **BaseClient**: Methods with `return_data_objects: false` now return parsed Hash/Array instead of raw `OAuth2::Response` objects

### Changed
- Removed redundant `strike_price` attribute from option instruments
- Removed account numbers from log messages for improved security

## [0.5.0] - 2025-11-03

### Added
- Vertical Roll Orders: Support for vertical roll orders that close an existing vertical spread and open a new one in a single order
- `VerticalRollOrder` class with 4-leg order structure for rolling positions
- Comprehensive tests for vertical roll orders including credit rolls, debit rolls, and stop limit orders

### Fixed
- Fixed typo in `OrderFactory` (SchwabRbL → SchwabRb)

## [0.4.0] - 2025-10-19

### Added
- Account Management System: New `AccountHashManager` class for managing accounts via friendly names instead of encrypted account hashes
- One-Cancels-Other (OCO) Orders: Support for OCO order types with comprehensive examples
- Stop Limit Orders: Added support for stop limit order types
- Order type and duration as configurable parameters across all order types
- Quick Start Guide (doc/QUICK_START.md) for new users
- Account Management documentation (doc/ACCOUNT_MANAGEMENT.md) with detailed usage examples
- Place Order Samples documentation (doc/PLACE_ORDER_SAMPLES.md) with examples for all order types
- Example script for placing OCO orders (examples/place_oco_order.rb)
- Configuration options for account management paths

### Changed
- Enhanced `BaseClient` with account name resolution - client methods can now accept account names or hashes
- Refactored order classes (IronCondorOrder, VerticalOrder, SingleOrder) to support order_type and duration parameters
- Improved `OrderFactory` to handle OCO and stop limit orders
- Updated bin/console with account hash manager initialization

### Fixed
- Fixed parameter order in client method calls

## [0.2.0] - 2025-07-20

### Added
- Comprehensive README documentation with all API features
- Enhanced authentication methods documentation
- Async support documentation and examples
- Order building examples with the Builder class
- Data objects explanation and usage
- Troubleshooting section for common issues
- Prerequisites and dependencies sections
- Environment variables configuration guide

### Changed
- Updated gemspec description to be more comprehensive
- Fixed GitHub URL references in README
- Improved example usage with more realistic scenarios
- Enhanced logging configuration documentation

### Fixed
- Corrected environment variable names (SCHWAB_LOG_LEVEL vs LOG_LEVEL)
- Fixed development commands in README (rake spec vs rake test)
- Updated allowed_push_host in gemspec to point to RubyGems

## [0.1.0] - 2024-11-08

- Initial release
