# schwab_rb: Schwab API Ruby Client

The `schwab_rb` gem is a Ruby client for interacting with the Schwab API. It provides a simple and flexible interface for accessing Schwab account data, placing orders, retrieving quotes, and more.

## Installation

Add this line to your application's Gemfile:

```ruby
bundle add schwab_rb
```

Or install it manually:

```bash
gem install schwab_rb
```

## Usage

### Setting Up Environment Variables

Before using the gem, ensure you have the following environment variables set:

- `SCHWAB_API_KEY`: Your Schwab API key.
- `SCHWAB_APP_SECRET`: Your Schwab application secret.
- `APP_CALLBACK_URL`: The callback URL for your application.
- `TOKEN_PATH`: Path to store the authentication token.
- `SCHWAB_ACCOUNT_NUMBER`: Your Schwab account number.
- `SCHWAB_LOGFILE`: (Optional) Path to the log file. Defaults to `STDOUT`.
- `LOG_LEVEL`: (Optional) Log level for the logger. Defaults to `WARN`. Possible values: `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`.

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

# Fetch account details
account = client.get_account('account_hash')
puts account.body

# Place an order
order = {
  symbol: 'AAPL',
  quantity: 10,
  instruction: 'BUY'
}
response = client.place_order('account_hash', order)
puts response.body
```

For more detailed examples, refer to the `examples/schwab.rb` file in the repository.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/schwab_rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

The gem is inspired by [schwab-py](https://pypi.org/project/schwab-py). The original implementation can be found [here](https://github.com/alexgolec/schwab-py).