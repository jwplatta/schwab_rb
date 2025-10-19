# Account Management Guide

The schwab_rb gem provides a secure and convenient way to manage multiple Schwab accounts using friendly account names instead of exposing account numbers or hashes in your code.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Account Names Setup](#account-names-setup)
- [Using Account Names](#using-account-names)
- [Security Best Practices](#security-best-practices)
- [Troubleshooting](#troubleshooting)
- [API Reference](#api-reference)

## Overview

Schwab's API requires account hashes for most operations, which:
- Change periodically (accounts get "rehashed")
- Are inconvenient to look up and copy
- Expose sensitive account numbers in code

schwab_rb provides an account name mapping system that:
- **Increases Security**: Account numbers never appear in your code
- **Improves Usability**: Reference accounts by friendly names like "my_trading_account"
- **Auto-Updates**: Account hashes refresh automatically
- **Handles Staleness**: Retries failed requests with fresh hashes

## Quick Start

### 1. Create Account Names File

Create `~/.schwab_rb/account_names.json` with your account mappings:

```json
{
  "my_trading_account": "12345678",
  "my_ira": "87654321",
  "my_roth_ira": "11223344"
}
```

### 2. Initialize Client and Fetch Hashes

```ruby
require "schwab_rb"

# Initialize client
client = SchwabRb::Auth.init_client_easy(
  ENV['SCHWAB_API_KEY'],
  ENV['SCHWAB_APP_SECRET'],
  ENV['SCHWAB_APP_CALLBACK_URL'],
  ENV['SCHWAB_TOKEN_PATH']
)

# Fetch account numbers and populate hashes
client.get_account_numbers
```

This automatically creates `~/.schwab_rb/account_hashes.json` with the name-to-hash mappings.

### 3. Use Account Names in API Calls

```ruby
# Get account by name
account = client.get_account(account_name: "my_trading_account")

# Place order using account name
order = client.place_order(order_spec, account_name: "my_ira")

# Get transactions
transactions = client.get_transactions(account_name: "my_roth_ira")
```

## Configuration

### Default Paths

By default, schwab_rb uses:
- `schwab_home`: `~/.schwab_rb`
- `account_hashes_path`: `~/.schwab_rb/account_hashes.json`
- `account_names_path`: `~/.schwab_rb/account_names.json`

### Custom Paths

#### Via Environment Variables

```bash
export SCHWAB_HOME="/custom/path"
export SCHWAB_ACCOUNT_HASHES_PATH="/custom/path/hashes.json"
export SCHWAB_ACCOUNT_NAMES_PATH="/custom/path/names.json"
```

#### Via Ruby Configuration

```ruby
SchwabRb.configure do |config|
  config.schwab_home = "/custom/path"
  config.account_hashes_path = "/custom/path/hashes.json"
  config.account_names_path = "/custom/path/names.json"
end
```

## Account Names Setup

### File Format

`account_names.json` is a simple JSON object mapping friendly names to 8-digit account numbers:

```json
{
  "descriptive_name": "account_number"
}
```

## Using Account Names

### Methods Supporting Account Names

All account-specific methods support both `account_hash` and `account_name`:

- `get_account(account_name:)` or `get_account(account_hash)`
- `get_order(order_id, account_name:)`
- `cancel_order(order_id, account_name:)`
- `get_account_orders(account_name:)`
- `place_order(order_spec, account_name:)`
- `replace_order(order_id, order_spec, account_name:)`
- `preview_order(order_spec, account_name:)`
- `get_transactions(account_name:)`
- `get_transaction(activity_id, account_name:)`

### Calling Patterns

```ruby
# Using account name (keyword argument) - RECOMMENDED
client.get_account(account_name: "my_trading_account")

# Using account hash (positional argument) - still works
client.get_account("ABC123HASH")

# Using account hash (keyword argument)
client.get_account(account_hash: "ABC123HASH")

# Priority: account_name always takes precedence
client.get_account("HASH1", account_name: "my_ira")  # Uses "my_ira"
```

### List Available Accounts

```ruby
# Get list of configured account names
names = client.available_account_names
# => ["my_trading_account", "my_ira", "my_roth_ira"]

puts "Available accounts:"
names.each { |name| puts "  - #{name}" }
```

## Security

### 1. Protect Your Files

The account files contain sensitive information:

```bash
# Set restrictive permissions
chmod 600 ~/.schwab_rb/account_names.json
chmod 600 ~/.schwab_rb/account_hashes.json

# Verify permissions
ls -l ~/.schwab_rb/
```

### 2. Don't Commit to Version Control

Add to `.gitignore`:

```
.schwab_rb/
**/account_names.json
**/account_hashes.json
```

### 3. Environment-Specific Configs

Use different configs per environment:

```ruby
# In development
SchwabRb.configure do |config|
  config.schwab_home = "~/.schwab_rb/development"
end

# In production
SchwabRb.configure do |config|
  config.schwab_home = ENV['SCHWAB_CONFIG_PATH']
end
```

## Troubleshooting

### Account Name Not Found

**Error**: `Account name 'my_account' not found in account hashes.`

**Solutions**:
1. Run `client.get_account_numbers` to populate hashes
2. Check spelling in `account_names.json`
3. Verify account number is correct

### Account Numbers File Missing

**Error**: `Account names file not found at ~/.schwab_rb/account_names.json`

**Solutions**:
1. Create the file with your account mappings (see [Quick Start](#quick-start))
2. Set custom path via config if file is elsewhere

### Account Not in API Response

**Warning**: `Account 'old_account' (98765432) not found in API response.`

This warning means an account in your `account_names.json` wasn't returned by the API.

**Possible Causes**:
- Account was closed
- Wrong account number in `account_names.json`
- Account not accessible with current API credentials

**Actions**:
1. Verify account status on Schwab website
2. Check account number in `account_names.json`
3. Remove closed accounts from config

### Stale Account Hashes

The gem automatically handles stale hashes:
1. Request fails with stale hash
2. Calls `get_account_numbers` to refresh
3. Retries request with new hash
4. If still fails, raises original error

## API Reference

### Client Methods

#### `available_account_names`

Returns list of configured account names.

```ruby
client.available_account_names
# => ["my_trading_account", "my_ira"]
```

**Returns**: `Array<String>` - List of account names from `account_names.json`
**Returns**: `[]` - Empty array if file doesn't exist

#### Account-Specific Methods

All methods accept either `account_name:` or `account_hash`:

```ruby
# Get account
client.get_account(account_name: "my_trading_account")
client.get_account("ABC123HASH")

# Get orders
client.get_account_orders(account_name: "my_ira", max_results: 10)

# Place order
client.place_order(order_spec, account_name: "my_trading_account")
```

### AccountHashManager

Direct access to the account hash manager:

```ruby
manager = SchwabRb::AccountHashManager.new

# Get available names
manager.available_account_names
# => ["my_trading_account", "my_ira"]

# Get hash by name
manager.get_hash_by_name("my_trading_account")
# => "ABC123HASH"

# Get all hashes
manager.get_all_hashes
# => {"my_trading_account" => "ABC123HASH", "my_ira" => "XYZ789HASH"}
```

---

For more information, see the [main README](../README.md) or visit [github.com/jwplatta/schwab_rb](https://github.com/jwplatta/schwab_rb).
