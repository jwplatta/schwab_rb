# schwab_rb: Schwab API Ruby Client

The `schwab_rb` gem is a Ruby client for interacting with the Schwab API. It provides a simple and flexible interface for accessing Schwab account data, placing orders, retrieving quotes, and more.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'schwab_rb'
```

Or install it manually:

```bash
gem install schwab_rb
```

Note: The gem requires Ruby 3.0.0 or higher.

## Prerequisites

Before using this gem, you'll need:

1. A Charles Schwab Developer Account
2. A registered application with Schwab to get your API key and secret
3. Your Schwab trading account number

## Dependencies

The gem depends on several key libraries:
- `async` and `async-http` for asynchronous HTTP operations
- `oauth2` for OAuth authentication
- `sinatra` and `puma` for the authentication callback server
- `dotenv` for environment variable management

## Usage

### Setting Up Environment Variables

Before using the gem, ensure you have the following environment variables set:

- `SCHWAB_API_KEY`: Your Schwab API key.
- `SCHWAB_APP_SECRET`: Your Schwab application secret.
- `APP_CALLBACK_URL`: The callback URL for your application.
- `TOKEN_PATH`: Path to store the authentication token.
- `SCHWAB_ACCOUNT_NUMBER`: Your Schwab account number.
- `SCHWAB_LOGFILE`: (Optional) Path to the log file. Defaults to `STDOUT`.
- `SCHWAB_LOG_LEVEL`: (Optional) Log level for the logger. Defaults to `WARN`. Possible values: `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`.
- `SCHWAB_SILENCE_OUTPUT`: (Optional) Set to `true` to disable logging output. Defaults to `false`.

You can also configure logging programmatically:

```ruby
SchwabRb.configure do |config|
  config.logger = Logger.new(STDOUT)
  config.log_level = 'INFO'
  config.silence_output = false
end
```

### Example Usage

Here is an example of how to use the `schwab_rb` gem:

```ruby
require 'schwab_rb'

# Initialize the client
client = SchwabRb::Auth.init_client_easy(
  ENV['SCHWAB_API_KEY'],
  ENV['SCHWAB_APP_SECRET'],
  ENV['APP_CALLBACK_URL'],
  ENV['TOKEN_PATH']
)

# Fetch a quote
quote = client.get_quote('AAPL')
puts quote.body

# Fetch multiple quotes
quotes = client.get_quotes(['AAPL', 'MSFT', 'GOOGL'])
puts quotes.body

# Fetch account details
account = client.get_account('account_hash')
puts account.body

# Get option chain
option_chain = client.get_option_chain(
  symbol: 'AAPL',
  strike_count: 10,
  include_non_standard: true
)

# Preview an order before placing
order = {
  orderType: 'MARKET',
  session: 'NORMAL',
  duration: 'DAY',
  orderLegCollection: [
    {
      instruction: 'BUY',
      quantity: 100,
      instrument: {
        symbol: 'AAPL',
        assetType: 'EQUITY'
      }
    }
  ]
}

preview = client.preview_order('account_hash', order)
puts preview.body

# Place the order
response = client.place_order('account_hash', order)
puts response.body

# Get price history
price_history = client.get_price_history(
  symbol: 'AAPL',
  period_type: :month,
  period: 3,
  frequency_type: :daily
)
```

## Data Objects

The gem includes structured data objects for better handling of API responses. Most API methods support a `return_data_objects` parameter (defaults to `true`) which returns parsed Ruby objects instead of raw JSON responses:

```ruby
# Returns structured data objects
quote = client.get_quote('AAPL')  # Returns Quote object
account = client.get_account('hash')  # Returns Account object

# Returns raw JSON response
quote_raw = client.get_quote('AAPL', return_data_objects: false)
```

Available data object types include:
- `Quote` - Stock and option quotes
- `Account` - Account information and balances
- `Order` - Order details and status
- `Transaction` - Transaction history
- `OptionChain` - Option chain data
- `PriceHistory` - Historical price data
- And more...

For more detailed examples, refer to the `examples/schwab.rb` file in the repository.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## API Features

The gem provides comprehensive access to the Schwab API, including:

### Account Information
- Get account details and balances
- Retrieve account numbers
- Get user preferences

### Orders
- Place orders (equity and options)
- Cancel orders
- Replace existing orders
- Preview orders before placing
- Get order details and history

### Market Data
- Real-time and delayed quotes for stocks and options
- Option chains with filtering capabilities
- Option expiration chains
- Price history with various time intervals
- Market movers
- Market hours information

### Transactions
- Get transaction history
- Retrieve individual transaction details

### Order Building
The gem includes a flexible order builder for creating complex orders:

```ruby
# Using the order builder for a simple equity buy
order = SchwabRb::Orders::Builder.new
  .set_session(:normal)
  .set_duration(:day)
  .set_order_type(:market)
  .add_equity_leg(:buy, 'AAPL', 100)
  .build

response = client.place_order('account_hash', order)
```

## Authentication Methods

The gem supports multiple authentication approaches:

1. **Easy Initialization** (Recommended): Automatically handles token storage and refresh
2. **Token File**: Initialize from a saved token file
3. **Login Flow**: Interactive browser-based authentication

### Easy Authentication Setup

```ruby
client = SchwabRb::Auth.init_client_easy(
  ENV['SCHWAB_API_KEY'],
  ENV['SCHWAB_APP_SECRET'],
  ENV['APP_CALLBACK_URL'],
  ENV['TOKEN_PATH']
)
```

This method will:
- Try to load an existing token from the specified path
- Automatically refresh the token if it's expired
- Fall back to the interactive login flow if no valid token exists

## Async Support

The gem supports both synchronous and asynchronous operations. For async usage:

```ruby
# Initialize async client
client = SchwabRb::Auth.init_client_easy(
  ENV['SCHWAB_API_KEY'],
  ENV['SCHWAB_APP_SECRET'],
  ENV['APP_CALLBACK_URL'],
  ENV['TOKEN_PATH'],
  asyncio: true
)

# Use async methods
client.get_quote('AAPL').then do |response|
  puts response.body
end
```

## Troubleshooting

### Token Issues
- Ensure your `TOKEN_PATH` environment variable points to a writable location
- Delete the token file and re-authenticate if you encounter persistent token errors
- Check that your API key and secret are correctly set in environment variables

### SSL/TLS Issues
- The gem uses SSL for all API communications
- If you encounter SSL errors, ensure your system's certificate store is up to date

### Rate Limiting
- The Schwab API has rate limits; implement appropriate delays between requests
- Use the gem's logging features to monitor API request/response patterns

For more detailed examples, refer to the `examples/schwab.rb` file in the repository.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jwplatta/schwab_rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

The gem is inspired by [schwab-py](https://pypi.org/project/schwab-py). The original implementation can be found [here](https://github.com/alexgolec/schwab-py).