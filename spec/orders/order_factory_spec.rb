# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SchwabRb::Orders::OrderFactory do
  describe '.build' do
    let(:account_number) { '123456789' }
    let(:quantity) { 1 }
    let(:price) { 1.50 }
    let(:order_builder) { instance_double(SchwabRb::Orders::Builder) }

    before do
      # Set up mocks for all order classes before any tests run
      allow(SchwabRb::Orders::IronCondorOrder).to receive(:build).and_return(order_builder)
      allow(SchwabRb::Orders::VerticalOrder).to receive(:build).and_return(order_builder)
      allow(SchwabRb::Orders::VerticalRollOrder).to receive(:build).and_return(order_builder)
      allow(SchwabRb::Orders::SingleOrder).to receive(:build).and_return(order_builder)
      allow(SchwabRb::Orders::OcoOrder).to receive(:build).and_return(order_builder)
    end

    context 'with an iron condor trade' do
      let(:iron_condor_options) do
        {
          strategy_type: SchwabRb::Order::ComplexOrderStrategyTypes::IRON_CONDOR,
          account_number: account_number,
          quantity: quantity,
          price: price,
          put_short_symbol: 'SPX_PUT_SHORT',
          put_long_symbol: 'SPX_PUT_LONG',
          call_short_symbol: 'SPX_CALL_SHORT',
          call_long_symbol: 'SPX_CALL_LONG'
        }
      end

      it 'delegates to IronCondorOrder.build with explicit parameters' do
        described_class.build(**iron_condor_options)
        expect(SchwabRb::Orders::IronCondorOrder).to have_received(:build).with(
          put_short_symbol: 'SPX_PUT_SHORT',
          put_long_symbol: 'SPX_PUT_LONG',
          call_short_symbol: 'SPX_CALL_SHORT',
          call_long_symbol: 'SPX_CALL_LONG',
          price: price,
          stop_price: nil,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :credit,
          order_instruction: :open,
          quantity: quantity
        )
      end

      it 'handles exit orders' do
        exit_options = iron_condor_options.merge(order_instruction: :exit)
        described_class.build(**exit_options)
        expect(SchwabRb::Orders::IronCondorOrder).to have_received(:build).with(
          put_short_symbol: 'SPX_PUT_SHORT',
          put_long_symbol: 'SPX_PUT_LONG',
          call_short_symbol: 'SPX_CALL_SHORT',
          call_long_symbol: 'SPX_CALL_LONG',
          price: price,
          stop_price: nil,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :credit,
          order_instruction: :exit,
          quantity: quantity
        )
      end

      it 'handles stop limit orders with stop_price' do
        stop_price = 1.00
        stop_limit_options = iron_condor_options.merge(stop_price: stop_price)
        described_class.build(**stop_limit_options)
        expect(SchwabRb::Orders::IronCondorOrder).to have_received(:build).with(
          put_short_symbol: 'SPX_PUT_SHORT',
          put_long_symbol: 'SPX_PUT_LONG',
          call_short_symbol: 'SPX_CALL_SHORT',
          call_long_symbol: 'SPX_CALL_LONG',
          price: price,
          stop_price: stop_price,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :credit,
          order_instruction: :open,
          quantity: quantity
        )
      end
    end

    context 'with a vertical spread trade' do
      let(:vertical_options) do
        {
          account_number: account_number,
          quantity: quantity,
          price: price,
          short_leg_symbol: 'SPX_SHORT_LEG',
          long_leg_symbol: 'SPX_LONG_LEG'
        }
      end

      context 'with call spread' do
        let(:call_spread_options) { vertical_options.merge(strategy_type: SchwabRb::Order::ComplexOrderStrategyTypes::VERTICAL) }

        it 'delegates to VerticalOrder.build with explicit parameters' do
          described_class.build(**call_spread_options)
          expect(SchwabRb::Orders::VerticalOrder).to have_received(:build).with(
            short_leg_symbol: 'SPX_SHORT_LEG',
            long_leg_symbol: 'SPX_LONG_LEG',
            price: price,
            stop_price: nil,
            order_type: nil,
            duration: SchwabRb::Orders::Duration::DAY,
            credit_debit: :credit,
            order_instruction: :open,
            quantity: quantity
          )
        end

        it 'handles exit orders' do
          exit_options = call_spread_options.merge(order_instruction: :exit)
          described_class.build(**exit_options)
          expect(SchwabRb::Orders::VerticalOrder).to have_received(:build).with(
            short_leg_symbol: 'SPX_SHORT_LEG',
            long_leg_symbol: 'SPX_LONG_LEG',
            price: price,
            stop_price: nil,
            order_type: nil,
            duration: SchwabRb::Orders::Duration::DAY,
            credit_debit: :credit,
            order_instruction: :exit,
            quantity: quantity
          )
        end

        it 'handles stop limit orders with stop_price' do
          stop_price = 1.00
          stop_limit_options = call_spread_options.merge(stop_price: stop_price)
          described_class.build(**stop_limit_options)
          expect(SchwabRb::Orders::VerticalOrder).to have_received(:build).with(
            short_leg_symbol: 'SPX_SHORT_LEG',
            long_leg_symbol: 'SPX_LONG_LEG',
            price: price,
            stop_price: stop_price,
            order_type: nil,
            duration: SchwabRb::Orders::Duration::DAY,
            credit_debit: :credit,
            order_instruction: :open,
            quantity: quantity
          )
        end
      end

      context 'with put spread' do
        let(:put_spread_options) { vertical_options.merge(strategy_type: SchwabRb::Order::ComplexOrderStrategyTypes::VERTICAL) }

        it 'delegates to VerticalOrder.build with explicit parameters' do
          described_class.build(**put_spread_options)
          expect(SchwabRb::Orders::VerticalOrder).to have_received(:build).with(
            short_leg_symbol: 'SPX_SHORT_LEG',
            long_leg_symbol: 'SPX_LONG_LEG',
            price: price,
            stop_price: nil,
            order_type: nil,
            duration: SchwabRb::Orders::Duration::DAY,
            credit_debit: :credit,
            order_instruction: :open,
            quantity: quantity
          )
        end

        it 'handles exit orders' do
          exit_options = put_spread_options.merge(order_instruction: :exit)
          described_class.build(**exit_options)
          expect(SchwabRb::Orders::VerticalOrder).to have_received(:build).with(
            short_leg_symbol: 'SPX_SHORT_LEG',
            long_leg_symbol: 'SPX_LONG_LEG',
            price: price,
            stop_price: nil,
            order_type: nil,
            duration: SchwabRb::Orders::Duration::DAY,
            credit_debit: :credit,
            order_instruction: :exit,
            quantity: quantity
          )
        end

        it 'handles stop limit orders with stop_price' do
          stop_price = 1.00
          stop_limit_options = put_spread_options.merge(stop_price: stop_price)
          described_class.build(**stop_limit_options)
          expect(SchwabRb::Orders::VerticalOrder).to have_received(:build).with(
            short_leg_symbol: 'SPX_SHORT_LEG',
            long_leg_symbol: 'SPX_LONG_LEG',
            price: price,
            stop_price: stop_price,
            order_type: nil,
            duration: SchwabRb::Orders::Duration::DAY,
            credit_debit: :credit,
            order_instruction: :open,
            quantity: quantity
          )
        end
      end
    end

    context 'with a single option order' do
      let(:single_options) do
        {
          strategy_type: SchwabRb::Order::OrderStrategyTypes::SINGLE,
          account_number: account_number,
          quantity: quantity,
          price: price,
          symbol: 'SPX_OPTION'
        }
      end

      it 'delegates to SingleOrder.build with explicit parameters' do
        described_class.build(**single_options)
        expect(SchwabRb::Orders::SingleOrder).to have_received(:build).with(
          symbol: 'SPX_OPTION',
          price: price,
          stop_price: nil,
          order_type: nil,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :credit,
          order_instruction: :open,
          quantity: quantity
        )
      end

      it 'handles exit orders' do
        exit_options = single_options.merge(order_instruction: :exit)
        described_class.build(**exit_options)
        expect(SchwabRb::Orders::SingleOrder).to have_received(:build).with(
          symbol: 'SPX_OPTION',
          price: price,
          stop_price: nil,
          order_type: nil,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :credit,
          order_instruction: :exit,
          quantity: quantity
        )
      end

      it 'handles stop limit orders with stop_price' do
        stop_price = 1.00
        stop_limit_options = single_options.merge(stop_price: stop_price)
        described_class.build(**stop_limit_options)
        expect(SchwabRb::Orders::SingleOrder).to have_received(:build).with(
          symbol: 'SPX_OPTION',
          price: price,
          stop_price: stop_price,
          order_type: nil,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :credit,
          order_instruction: :open,
          quantity: quantity
        )
      end
    end

    context 'with a vertical roll order' do
      let(:vertical_roll_options) do
        {
          strategy_type: SchwabRb::Order::ComplexOrderStrategyTypes::VERTICAL_ROLL,
          account_number: account_number,
          quantity: quantity,
          price: price,
          close_short_leg_symbol: 'SPX_CLOSE_SHORT',
          close_long_leg_symbol: 'SPX_CLOSE_LONG',
          open_short_leg_symbol: 'SPX_OPEN_SHORT',
          open_long_leg_symbol: 'SPX_OPEN_LONG'
        }
      end

      it 'delegates to VerticalRollOrder.build with explicit parameters' do
        described_class.build(**vertical_roll_options)
        expect(SchwabRb::Orders::VerticalRollOrder).to have_received(:build).with(
          close_short_leg_symbol: 'SPX_CLOSE_SHORT',
          close_long_leg_symbol: 'SPX_CLOSE_LONG',
          open_short_leg_symbol: 'SPX_OPEN_SHORT',
          open_long_leg_symbol: 'SPX_OPEN_LONG',
          price: price,
          stop_price: nil,
          order_type: nil,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :credit,
          quantity: quantity
        )
      end

      it 'handles debit rolls' do
        debit_options = vertical_roll_options.merge(credit_debit: :debit)
        described_class.build(**debit_options)
        expect(SchwabRb::Orders::VerticalRollOrder).to have_received(:build).with(
          close_short_leg_symbol: 'SPX_CLOSE_SHORT',
          close_long_leg_symbol: 'SPX_CLOSE_LONG',
          open_short_leg_symbol: 'SPX_OPEN_SHORT',
          open_long_leg_symbol: 'SPX_OPEN_LONG',
          price: price,
          stop_price: nil,
          order_type: nil,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :debit,
          quantity: quantity
        )
      end

      it 'handles stop limit orders with stop_price' do
        stop_price = 1.00
        stop_limit_options = vertical_roll_options.merge(stop_price: stop_price)
        described_class.build(**stop_limit_options)
        expect(SchwabRb::Orders::VerticalRollOrder).to have_received(:build).with(
          close_short_leg_symbol: 'SPX_CLOSE_SHORT',
          close_long_leg_symbol: 'SPX_CLOSE_LONG',
          open_short_leg_symbol: 'SPX_OPEN_SHORT',
          open_long_leg_symbol: 'SPX_OPEN_LONG',
          price: price,
          stop_price: stop_price,
          order_type: nil,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :credit,
          quantity: quantity
        )
      end
    end

    context 'with an OCO order' do
      let(:child_order_specs) do
        [
          {
            strategy_type: SchwabRb::Order::OrderStrategyTypes::SINGLE,
            symbol: 'XYZ   240315C00500000',
            price: 45.97,
            account_number: account_number,
            order_instruction: :close,
            credit_debit: :credit,
            quantity: 2
          },
          {
            strategy_type: SchwabRb::Order::OrderStrategyTypes::SINGLE,
            symbol: 'XYZ   240315C00500000',
            price: 37.00,
            account_number: account_number,
            order_instruction: :close,
            credit_debit: :credit,
            quantity: 2
          }
        ]
      end

      let(:oco_options) do
        {
          strategy_type: SchwabRb::Order::OrderStrategyTypes::OCO,
          child_order_specs: child_order_specs
        }
      end

      it 'delegates to OcoOrder.build with child order specifications' do
        described_class.build(**oco_options)
        expect(SchwabRb::Orders::OcoOrder).to have_received(:build).with(
          child_order_specs: child_order_specs
        )
      end
    end

    context 'with an unsupported trade type' do
      let(:unsupported_options) do
        {
          strategy_type: 'unsupported',
          account_number: account_number,
          quantity: quantity
        }
      end

      it 'raises an error for unsupported trade strategies' do
        expect {
          described_class.build(**unsupported_options)
        }.to raise_error('Unsupported trade strategy: unsupported')
      end
    end

    context 'with no strategy type specified' do
      let(:options) do
        {
          account_number: account_number,
          quantity: quantity
        }
      end

      it 'raises an error for missing strategy type' do
        expect {
          described_class.build(**options)
        }.to raise_error('Unsupported trade strategy: none')
      end
    end
  end
end
