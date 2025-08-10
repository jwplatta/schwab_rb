# frozen_string_literal: true

require 'schwab_rb'

module SchwabRb
  module Orders
    class VerticalOrder
      class << self
        def build(
          short_leg_symbol:, long_leg_symbol:, price:,
          account_number:, credit_debit: :credit, order_instruction: :open, quantity: 1
        )
          schwab_order_builder.new.tap do |builder|
            builder.set_account_number(account_number)
            builder.set_order_strategy_type('SINGLE')
            builder.set_session(SchwabRb::Orders::Session::NORMAL)
            builder.set_duration(SchwabRb::Orders::Duration::DAY)
            builder.set_order_type(order_type(credit_debit))
            builder.set_complex_order_strategy_type(SchwabRb::Order::ComplexOrderStrategyTypes::VERTICAL)
            builder.set_quantity(quantity)
            builder.set_price(price)
            builder.add_option_leg(
              short_leg_instruction(order_instruction, credit_debit),
              short_leg_symbol,
              quantity
            )
            builder.add_option_leg(
              long_leg_instruction(order_instruction, credit_debit),
              long_leg_symbol,
              quantity
            )
          end
        end

        def order_type(credit_debit)
          if credit_debit == :credit
            SchwabRb::Order::Types::NET_CREDIT
          else
            SchwabRb::Order::Types::NET_DEBIT
          end
        end

        def short_leg_instruction(order_instruction, credit_debit)
          if order_instruction == :open && credit_debit == :credit
            SchwabRb::Orders::OptionInstructions::SELL_TO_OPEN
          elsif order_instruction == :open && credit_debit == :debit
            SchwabRb::Orders::OptionInstructions::BUY_TO_OPEN
          elsif order_instruction == :close && credit_debit == :credit
            SchwabRb::Orders::OptionInstructions::SELL_TO_CLOSE
          elsif order_instruction == :close && credit_debit == :debit
            SchwabRb::Orders::OptionInstructions::BUY_TO_CLOSE
          else
            raise "Unsupported order instruction: #{order_instruction} with credit/debit: #{credit_debit}"
          end
        end

        def long_leg_instruction(order_instruction, credit_debit)
          if order_instruction == :open && credit_debit == :credit
            SchwabRb::Orders::OptionInstructions::BUY_TO_OPEN
          elsif order_instruction == :close && credit_debit == :credit
            SchwabRb::Orders::OptionInstructions::SELL_TO_CLOSE
          elsif order_instruction == :open && credit_debit == :debit
            SchwabRb::Orders::OptionInstructions::SELL_TO_OPEN
          elsif order_instruction == :close && credit_debit == :debit
            SchwabRb::Orders::OptionInstructions::BUY_TO_CLOSE
          else
            raise "Unsupported order instruction: #{order_instruction} with credit/debit: #{credit_debit}"
          end
        end

        def schwab_order_builder
          SchwabRb::Orders::Builder
        end
      end
    end
  end
end
