# frozen_string_literal: true

require "schwab_rb"

module SchwabRb
  module Orders
    class VerticalRollOrder
      class << self
        def build(
          close_short_leg_symbol:,
          close_long_leg_symbol:,
          open_short_leg_symbol:,
          open_long_leg_symbol:,
          price:,
          stop_price: nil,
          order_type: nil,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :credit,
          quantity: 1
        )
          schwab_order_builder.new.tap do |builder|
            builder.set_order_strategy_type(SchwabRb::Order::OrderStrategyTypes::SINGLE)
            builder.set_session(SchwabRb::Orders::Session::NORMAL)
            builder.set_duration(duration)
            builder.set_order_type(order_type || determine_order_type(credit_debit))
            builder.set_complex_order_strategy_type(SchwabRb::Order::ComplexOrderStrategyTypes::VERTICAL_ROLL)
            builder.set_quantity(quantity)
            builder.set_price(price)
            builder.set_stop_price(stop_price) if stop_price && order_type == SchwabRb::Order::Types::STOP_LIMIT

            # Close the existing spread (opposite instructions)
            builder.add_option_leg(
              SchwabRb::Orders::OptionInstructions::BUY_TO_CLOSE,
              close_short_leg_symbol,
              quantity
            )
            builder.add_option_leg(
              SchwabRb::Orders::OptionInstructions::SELL_TO_CLOSE,
              close_long_leg_symbol,
              quantity
            )

            # Open the new spread
            builder.add_option_leg(
              SchwabRb::Orders::OptionInstructions::SELL_TO_OPEN,
              open_short_leg_symbol,
              quantity
            )
            builder.add_option_leg(
              SchwabRb::Orders::OptionInstructions::BUY_TO_OPEN,
              open_long_leg_symbol,
              quantity
            )
          end
        end

        def determine_order_type(credit_debit)
          if credit_debit == :credit
            SchwabRb::Order::Types::NET_CREDIT
          else
            SchwabRb::Order::Types::NET_DEBIT
          end
        end

        def schwab_order_builder
          SchwabRb::Orders::Builder
        end
      end
    end
  end
end
