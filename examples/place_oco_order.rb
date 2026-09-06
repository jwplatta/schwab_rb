#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'schwab_rb'
require 'dotenv'
require 'pry'

Dotenv.load

# Example: Place an OCO (One Cancels Another) order
#
# This example demonstrates how to create an OCO order where two orders
# are submitted simultaneously, and if one fills, the other is automatically cancelled.
#

# SchwabRb::Configuration.configure do |config|
# config.schwab_home = "/path/to/your/schwab_rb_home"
# config.log_level = "DEBUG"
# end

client = SchwabRb::Auth.init_client_easy(
  ENV['SCHWAB_API_KEY'],
  ENV['SCHWAB_APP_SECRET'],
  ENV['SCHWAB_APP_CALLBACK_URL'],
  ENV['SCHWAB_TOKEN_PATH']
)

puts "Example 1: OCO order with take profit and stop loss"
puts "=" * 60


symbols = [
  "SPXW  251020P06510000", # long put
  "SPXW  251020P06530000", # short put
  "SPXW  251020C06790000", # long call
  "SPXW  251020C06770000",  # short call
]

oco_order = SchwabRb::Orders::OrderFactory.build(
  strategy_type: SchwabRb::Order::OrderStrategyTypes::OCO,
  child_order_specs: [
    {
      strategy_type: SchwabRb::Order::ComplexOrderStrategyTypes::VERTICAL,
      short_leg_symbol: "SPXW  251020P06530000",
      long_leg_symbol: "SPXW  251020P06510000",
      order_type: SchwabRb::Order::Types::STOP_LIMIT,
      price: 2.1,
      stop_price: 2.0,
      order_instruction: :close,
      credit_debit: :debit,
      quantity: 2
    },
    {
      strategy_type: SchwabRb::Order::ComplexOrderStrategyTypes::VERTICAL,
      short_leg_symbol: "SPXW  251020C06770000",
      long_leg_symbol: "SPXW  251020C06790000",
      order_type: SchwabRb::Order::Types::STOP_LIMIT,
      price: 2.1,
      stop_price: 2.0,
      order_instruction: :close,
      credit_debit: :debit,
      quantity: 2
    }
  ]
)

built_order = oco_order.build

binding.pry

# response = client.place_order(built_order)

binding.pry
