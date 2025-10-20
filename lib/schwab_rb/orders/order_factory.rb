# frozen_string_literal: true

require_relative "iron_condor_order"
require_relative "vertical_order"
require_relative "single_order"
require_relative "oco_order"
require_relative "order"

module SchwabRb
  module Orders
    class OrderFactory
      class << self
        def build(**options)
          case options[:strategy_type] || "none"
          when SchwabRb::Order::ComplexOrderStrategyTypes::IRON_CONDOR
            IronCondorOrder.build(
              put_short_symbol: options[:put_short_symbol],
              put_long_symbol: options[:put_long_symbol],
              call_short_symbol: options[:call_short_symbol],
              call_long_symbol: options[:call_long_symbol],
              price: options[:price],
              stop_price: options[:stop_price],
              duration: options[:duration] || SchwabRb::Orders::Duration::DAY,
              credit_debit: options[:credit_debit] || :credit,
              order_instruction: options[:order_instruction] || :open,
              quantity: options[:quantity] || 1
            )
          when SchwabRb::Order::ComplexOrderStrategyTypes::VERTICAL # call or put spreads
            VerticalOrder.build(
              short_leg_symbol: options[:short_leg_symbol],
              long_leg_symbol: options[:long_leg_symbol],
              price: options[:price],
              stop_price: options[:stop_price],
              order_type: options[:order_type],
              duration: options[:duration] || SchwabRb::Orders::Duration::DAY,
              credit_debit: options[:credit_debit] || :credit,
              order_instruction: options[:order_instruction] || :open,
              quantity: options[:quantity] || 1
            )
          when SchwabRb::Order::OrderStrategyTypes::SINGLE
            SingleOrder.build(
              symbol: options[:symbol],
              price: options[:price],
              stop_price: options[:stop_price],
              order_type: options[:order_type],
              duration: options[:duration] || SchwabRb::Orders::Duration::DAY,
              credit_debit: options[:credit_debit] || :credit,
              order_instruction: options[:order_instruction] || :open,
              quantity: options[:quantity] || 1
            )
          when SchwabRb::Order::OrderStrategyTypes::OCO
            OcoOrder.build(
              child_order_specs: options[:child_order_specs]
            )
          else
            raise "Unsupported trade strategy: #{options[:strategy_type] || 'none'}"
          end
        end
      end
    end
  end
end
