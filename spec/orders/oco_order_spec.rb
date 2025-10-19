# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SchwabRb::Orders::OcoOrder do
  describe '.build' do
    let(:account_number) { '123456789' }

    context 'with two single option child orders' do
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

      it 'creates an OCO order with two child orders' do
        result = described_class.build(child_order_specs: child_order_specs)

        expect(result).to be_a(SchwabRb::Orders::Builder)
        built_order = result.build

        expect(built_order['orderStrategyType']).to eq(SchwabRb::Order::OrderStrategyTypes::OCO)
        expect(built_order['childOrderStrategies']).to be_an(Array)
        expect(built_order['childOrderStrategies'].length).to eq(2)
      end

      it 'properly builds each child order' do
        result = described_class.build(child_order_specs: child_order_specs)
        built_order = result.build

        child_orders = built_order['childOrderStrategies']

        # First child order
        expect(child_orders[0]['orderType']).to eq('NET_CREDIT')
        expect(child_orders[0]['price']).to eq(45.97)
        expect(child_orders[0]['orderStrategyType']).to eq('SINGLE')
        expect(child_orders[0]['orderLegCollection']).to be_an(Array)

        # Second child order
        expect(child_orders[1]['orderType']).to eq('NET_CREDIT')
        expect(child_orders[1]['price']).to eq(37.00)
        expect(child_orders[1]['orderStrategyType']).to eq('SINGLE')
        expect(child_orders[1]['orderLegCollection']).to be_an(Array)
      end
    end

    context 'with three child orders' do
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
            price: 40.00,
            account_number: account_number,
            order_instruction: :close,
            credit_debit: :credit,
            quantity: 2
          },
          {
            strategy_type: SchwabRb::Order::OrderStrategyTypes::SINGLE,
            symbol: 'XYZ   240315C00500000',
            price: 35.00,
            account_number: account_number,
            order_instruction: :close,
            credit_debit: :credit,
            quantity: 2
          }
        ]
      end

      it 'creates an OCO order with three child orders' do
        result = described_class.build(child_order_specs: child_order_specs)
        built_order = result.build

        expect(built_order['orderStrategyType']).to eq(SchwabRb::Order::OrderStrategyTypes::OCO)
        expect(built_order['childOrderStrategies'].length).to eq(3)
      end
    end

    context 'with mixed order types (single and vertical)' do
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
            strategy_type: SchwabRb::Order::ComplexOrderStrategyTypes::VERTICAL,
            short_leg_symbol: 'XYZ   240315P00045000',
            long_leg_symbol: 'XYZ   240315P00043000',
            price: 0.10,
            account_number: account_number,
            credit_debit: :debit,
            order_instruction: :open,
            quantity: 2
          }
        ]
      end

      it 'creates an OCO order with different child order types' do
        result = described_class.build(child_order_specs: child_order_specs)
        built_order = result.build

        expect(built_order['orderStrategyType']).to eq(SchwabRb::Order::OrderStrategyTypes::OCO)
        expect(built_order['childOrderStrategies'].length).to eq(2)

        # First child is a single option order
        expect(built_order['childOrderStrategies'][0]['orderType']).to eq('NET_CREDIT')

        # Second child is a vertical spread
        expect(built_order['childOrderStrategies'][1]['orderType']).to eq('NET_DEBIT')
        expect(built_order['childOrderStrategies'][1]['complexOrderStrategyType']).to eq('VERTICAL')
      end
    end

    context 'with only one child order' do
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
          }
        ]
      end

      it 'raises an ArgumentError' do
        expect {
          described_class.build(child_order_specs: child_order_specs)
        }.to raise_error(ArgumentError, 'OCO orders require at least 2 child orders')
      end
    end

    context 'with empty child orders array' do
      let(:child_order_specs) { [] }

      it 'raises an ArgumentError' do
        expect {
          described_class.build(child_order_specs: child_order_specs)
        }.to raise_error(ArgumentError, 'OCO orders require at least 2 child orders')
      end
    end
  end
end
