# frozen_string_literal: true

require 'rspec'
require 'schwab_rb'

RSpec.describe SchwabRb::DataObjects::OrderLeg do
  let(:raw_data) do
    orders = JSON.parse(File.read('spec/fixtures/orders.json'), symbolize_names: true)
    orders.flat_map { |order| order[:orderLegCollection] || [] }.first
  end

  describe '.build' do
    it 'creates an order leg object from raw data' do
      order_leg = SchwabRb::DataObjects::OrderLeg.build(raw_data)

      expect(order_leg).to be_an_instance_of(SchwabRb::DataObjects::OrderLeg)
      expect(order_leg.leg_id).to eq(raw_data[:legId])
      expect(order_leg.order_leg_type).to eq(raw_data[:orderLegType])
      expect(order_leg.quantity).to eq(raw_data[:quantity])
      expect(order_leg.instruction).to eq(raw_data[:instruction])
      expect(order_leg.position_effect).to eq(raw_data[:positionEffect])

      expect(order_leg.instrument).to be_an_instance_of(SchwabRb::DataObjects::Instrument)
    end
  end

  describe '#to_h' do
    it 'converts the order leg object back to a hash with the same structure as the input data' do
      order_leg = SchwabRb::DataObjects::OrderLeg.build(raw_data)
      leg_hash = order_leg.to_h

      expect(leg_hash[:legId]).to eq(raw_data[:legId])
      expect(leg_hash[:orderLegType]).to eq(raw_data[:orderLegType])
      expect(leg_hash[:quantity]).to eq(raw_data[:quantity])
      expect(leg_hash[:instruction]).to eq(raw_data[:instruction])
      expect(leg_hash[:positionEffect]).to eq(raw_data[:positionEffect])

      # Verify that instrument data is also converted to a hash
      expect(leg_hash[:instrument]).to be_a(Hash)
      expect(leg_hash[:instrument][:symbol]).to eq(raw_data[:instrument][:symbol])
    end
  end
end
