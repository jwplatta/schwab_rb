# Quick Start Guide

Get started with schwab_rb in 5 minutes.

## 1. Install

```bash
gem install schwab_rb
```

Or add to your Gemfile:

```ruby
gem 'schwab_rb'
```

## 2. Get Your Schwab API Credentials

1. Go to [Schwab Developer Portal](https://developer.schwab.com/)
2. Create an app to get:
   - **API Key** (App Key)
   - **App Secret** (Secret)
   - **Callback URL** (use `https://127.0.0.1:8182` for local development)

## 3. Set Up Environment Variables

Create a `.env` file:

```bash
SCHWAB_API_KEY=your_api_key_here
SCHWAB_APP_SECRET=your_app_secret_here
SCHWAB_APP_CALLBACK_URL=https://127.0.0.1:8182
SCHWAB_TOKEN_PATH=~/.schwab_rb/token.json
```

## 4. Initialize Client (First Time)

```ruby
require 'schwab_rb'
require 'dotenv/load'

# This will open your browser for authentication
client = SchwabRb::Auth.init_client_easy(
  ENV['SCHWAB_API_KEY'],
  ENV['SCHWAB_APP_SECRET'],
  ENV['SCHWAB_APP_CALLBACK_URL'],
  ENV['SCHWAB_TOKEN_PATH']
)

puts "✓ Authenticated successfully!"
```

**What happens:**
- Browser opens to Schwab login
- You log in and authorize
- Token saved to `~/.schwab_rb/token.json`
- Client ready to use!

## 5. Make Your First API Call

```ruby
# Get your accounts
accounts = client.get_accounts

accounts.each do |account|
  puts "Account: #{account.account_number}"
  puts "Type: #{account.type}"
  puts "Value: $#{account.balance.total_value}"
  puts "---"
end
```

## 6. Set Up Account Names (Optional but Recommended)

Create `~/.schwab_rb/account_names.json`:

```json
{
  "my_trading": "12345678",
  "my_ira": "87654321"
}
```

Populate account hashes:

```ruby
client.get_account_numbers
```

Now use friendly names:

```ruby
# Instead of:
# account = client.get_account("ABC123HASH")

# Do this:
account = client.get_account(account_name: "my_trading")
```

## Common Operations

### Get Account Info

```ruby
account = client.get_account(account_name: "my_trading")
puts "Buying Power: $#{account.balance.buying_power}"
```

### Get Quotes

```ruby
quote = client.get_quote("AAPL")
puts "#{quote.symbol}: $#{quote.last_price}"
```

### Get Price History

```ruby
history = client.get_price_history_every_day(
  "AAPL",
  start_datetime: DateTime.now - 30
)

puts "#{history.candles.size} days of data"
history.candles.last(5).each do |candle|
  puts "#{candle.date}: $#{candle.close}"
end
```

### Place Order (Market Buy)

```ruby
order = SchwabRb::Orders::Builder.new
  .set_session(:normal)
  .set_duration(:day)
  .set_order_type(:market)
  .add_equity_leg(:buy, 'AAPL', 10)
  .build

response = client.place_order(order, account_name: "my_trading")
puts "Order placed!"
```

### Get Orders

```ruby
orders = client.get_account_orders(account_name: "my_trading")

orders.each do |order|
  puts "#{order.status}: #{order.order_leg_collection.first.quantity} shares of #{order.order_leg_collection.first.instrument.symbol}"
end
```

### Get Transactions

```ruby
transactions = client.get_transactions(
  account_name: "my_trading",
  start_date: DateTime.now - 7
)

puts "#{transactions.size} transactions in the last week"
```

## Configuration (Optional)

```ruby
SchwabRb.configure do |config|
  # Logging
  config.log_level = "INFO"
  config.log_file = "schwab.log"

  # Account management
  config.schwab_home = "~/.schwab_rb"
  config.account_names_path = "~/.schwab_rb/account_names.json"
  config.account_hashes_path = "~/.schwab_rb/account_hashes.json"
end
```

## Next Steps

- **Trading**: See [examples/](../examples/) for order placement examples
- **Account Management**: Read [ACCOUNT_MANAGEMENT.md](./ACCOUNT_MANAGEMENT.md) for multi-account setup
- **API Reference**: Check the [main README](../README.md) for complete API documentation

## Troubleshooting

**Authentication fails?**
- Check your API credentials
- Make sure callback URL matches exactly
- Try deleting `~/.schwab_rb/token.json` and re-authenticating

**Token expired?**
- The client automatically refreshes tokens
- If issues persist, re-authenticate with `init_client_easy`

**Can't find account?**
- Run `client.get_account_numbers` to refresh account hashes
- Check `account_names.json` for typos
- Use `client.available_account_names` to see configured accounts

## Example Script

```ruby
#!/usr/bin/env ruby
require 'schwab_rb'
require 'dotenv/load'

# Initialize
client = SchwabRb::Auth.init_client_easy(
  ENV['SCHWAB_API_KEY'],
  ENV['SCHWAB_APP_SECRET'],
  ENV['SCHWAB_APP_CALLBACK_URL'],
  ENV['SCHWAB_TOKEN_PATH']
)

# Get available accounts
names = client.available_account_names
puts "Available accounts: #{names.join(', ')}"

# Check account balance
account = client.get_account(account_name: names.first)
puts "\n#{names.first}:"
puts "  Total Value: $#{account.balance.total_value}"
puts "  Cash: $#{account.balance.cash_balance}"
puts "  Buying Power: $#{account.balance.buying_power}"

# Get a quote
quote = client.get_quote("SPY")
puts "\nSPY: $#{quote.last_price}"

puts "\n✓ All done!"
```

---

**Need Help?**
- Check the [main README](../README.md)
- Review [examples/](../examples/)
