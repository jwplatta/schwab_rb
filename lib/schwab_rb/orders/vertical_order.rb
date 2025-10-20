# frozen_string_literal: true

require "schwab_rb"

module SchwabRb
  module Orders
    class VerticalOrder
      class << self
        def build(
          short_leg_symbol:, long_leg_symbol:,
          price:,
          stop_price: nil,
          order_type: nil,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :credit,
          order_instruction: :open, quantity: 1
        )
          schwab_order_builder.new.tap do |builder|
            builder.set_order_strategy_type(SchwabRb::Order::OrderStrategyTypes::SINGLE)
            builder.set_session(SchwabRb::Orders::Session::NORMAL)
            builder.set_duration(duration)
            builder.set_order_type(order_type || determine_order_type(credit_debit))
            builder.set_complex_order_strategy_type(SchwabRb::Order::ComplexOrderStrategyTypes::VERTICAL)
            builder.set_quantity(quantity)
            builder.set_price(price)
            builder.set_stop_price(stop_price) if stop_price && order_type == SchwabRb::Order::Types::STOP_LIMIT
            builder.add_option_leg(
              short_leg_instruction(order_instruction),
              short_leg_symbol,
              quantity
            )
            builder.add_option_leg(
              long_leg_instruction(order_instruction),
              long_leg_symbol,
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

        def short_leg_instruction(order_instruction)
          if order_instruction == :open
            SchwabRb::Orders::OptionInstructions::SELL_TO_OPEN
          elsif order_instruction == :close
            SchwabRb::Orders::OptionInstructions::BUY_TO_CLOSE
          else
            raise "Unsupported order instruction: #{order_instruction}"
          end
        end

        def long_leg_instruction(order_instruction)
          if order_instruction == :open
            SchwabRb::Orders::OptionInstructions::BUY_TO_OPEN
          elsif order_instruction == :close
            SchwabRb::Orders::OptionInstructions::SELL_TO_CLOSE
          else
            raise "Unsupported order instruction: #{order_instruction}"
          end
        end

        def schwab_order_builder
          SchwabRb::Orders::Builder
        end
      end
    end
  end
end
