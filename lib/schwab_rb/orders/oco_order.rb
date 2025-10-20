# frozen_string_literal: true

require_relative 'order_factory'

module SchwabRb
  module Orders
    class OcoOrder
      class << self
        # Build an OCO (One Cancels Another) order with 2 or more child orders
        #
        # @param child_order_specs [Array<Hash>] Array of order specifications for child orders.
        #   Each spec should include all parameters needed for OrderFactory.build
        # @return [SchwabRb::Orders::Builder] A builder configured with OCO order structure
        #
        # @example Simple OCO with two equity orders
        #   OcoOrder.build(
        #     child_order_specs: [
        #       {
        #         strategy_type: 'single',
        #         symbol: 'XYZ   240315C00500000',
        #         price: 45.97,
        #         account_number: '12345',
        #         order_instruction: :close,
        #         credit_debit: :credit,
        #         quantity: 2
        #       },
        #       {
        #         strategy_type: 'single',
        #         symbol: 'XYZ   240315C00500000',
        #         price: 37.00,
        #         stop_price: 37.03,
        #         account_number: '12345',
        #         order_instruction: :close,
        #         credit_debit: :credit,
        #         quantity: 2
        #       }
        #     ]
        #   )
        def build(child_order_specs:)
          raise ArgumentError, "OCO orders require at least 2 child orders" if child_order_specs.length < 2

          builder = schwab_order_builder.new
          builder.set_order_strategy_type(SchwabRb::Order::OrderStrategyTypes::OCO)

          # Build each child order using OrderFactory
          child_order_specs.each do |child_spec|
            child_order = build_child_order(child_spec)
            builder.add_child_order_strategy(child_order)
          end

          builder
        end

        private

        def build_child_order(child_spec)
          # Use OrderFactory to recursively build child orders
          # This allows OCO orders to contain any type of order (single, vertical, iron condor, etc.)

          OrderFactory.build(**child_spec)
        end

        def schwab_order_builder
          SchwabRb::Orders::Builder
        end
      end
    end
  end
end
