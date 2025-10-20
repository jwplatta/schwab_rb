## [Unreleased]

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
