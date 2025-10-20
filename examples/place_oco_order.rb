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
# end

CURRENT_ACCT = "TRADING_BROKERAGE_ACCOUNT"
acct_manager = SchwabRb::AccountHashManager.new

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
      stop:
      price: 0.3,
      order_instruction: :close,
      credit_debit: :debit,
      quantity: 1
    },
    {
      strategy_type: SchwabRb::Order::ComplexOrderStrategyTypes::VERTICAL,
      short_leg_symbol: "SPXW  251020C06770000",
      long_leg_symbol: "SPXW  251020C06790000",
      order_type: SchwabRb::Order::Types::STOP_LIMIT,
      price: 0.3,
      order_instruction: :close,
      credit_debit: :debit,
      quantity: 1
    }
  ]
)

built_order = oco_order.build


response = client.place_order(built_order, account_name: CURRENT_ACCT)

binding.pry

exit

all_statuses = [
  "AWAITING_PARENT_ORDER",
  "AWAITING_CONDITION",
  "AWAITING_STOP_CONDITION",
  "AWAITING_MANUAL_REVIEW",
  "ACCEPTED",
  "AWAITING_UR_OUT",
  "PENDING_ACTIVATION",
  "QUEUED",
  "WORKING",
  "REJECTED",
  "PENDING_CANCEL",
  # "CANCELED",
  "PENDING_REPLACE",
  "REPLACED",
  "FILLED",
  "EXPIRED",
  "NEW",
  "AWAITING_RELEASE_TIME",
  "PENDING_ACKNOWLEDGEMENT",
  "PENDING_RECALL",
  "UNKNOWN"
]

current_orders = nil
all_statuses.each do |status|
  current_orders = client.get_account_orders(
    account_name: CURRENT_ACCT, status: status, from_entered_datetime: (Time.now - 24 * 60 * 60 * 3).to_datetime
  )

  if current_orders.empty?
    puts "No orders with status #{status}"
  else
    puts "Orders with status #{status}:"
    break
  end
end