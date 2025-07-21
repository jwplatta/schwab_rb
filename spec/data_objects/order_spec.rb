# frozen_string_literal: true

require "rspec"
require "schwab_rb"
require "date"

RSpec.describe SchwabRb::DataObjects::Order do
  let(:raw_data) do
    JSON.parse(File.read("spec/fixtures/orders.json"), symbolize_names: true)
  end

  describe ".build" do
    it "creates an order object from raw data" do
      raw_data.each do |data|
        order = SchwabRb::DataObjects::Order.build(data)
        expect(order).to be_an_instance_of SchwabRb::DataObjects::Order
        order.order_leg_collection.each do |leg|
          expect(leg).to be_an_instance_of SchwabRb::DataObjects::OrderLeg
        end

        order.order_activity_collection.each do |activity|
          expect(activity).to be_an_instance_of SchwabRb::DataObjects::OrderActivity
          activity.execution_legs.each do |execution_leg|
            expect(execution_leg).to be_an_instance_of SchwabRb::DataObjects::ExecutionLeg
          end
        end
      end
    end
  end

  describe "#to_h" do
    it "converts the order object back to a hash with the same structure as the input data" do
      raw_data.each do |data|
        order = SchwabRb::DataObjects::Order.build(data)
        order_hash = order.to_h

        # Basic fields should match
        expect(order_hash[:duration]).to eq(data[:duration])
        expect(order_hash[:orderType]).to eq(data[:orderType])
        expect(order_hash[:complexOrderStrategyType]).to eq(data[:complexOrderStrategyType])
        expect(order_hash[:quantity]).to eq(data[:quantity])
        expect(order_hash[:filledQuantity]).to eq(data[:filledQuantity])
        expect(order_hash[:remainingQuantity]).to eq(data[:remainingQuantity])
        expect(order_hash[:price]).to eq(data[:price])
        expect(order_hash[:orderStrategyType]).to eq(data[:orderStrategyType])
        expect(order_hash[:orderId]).to eq(data[:orderId])
        expect(order_hash[:status]).to eq(data[:status])

        # DateTime fields should be formatted as ISO8601 strings
        if data[:enteredTime]
          expect(order_hash[:enteredTime]).to be_a(String)
          expect(DateTime.parse(order_hash[:enteredTime])).to be_a(DateTime)
        else
          expect(order_hash[:enteredTime]).to be_nil
        end

        if data[:closeTime]
          expect(order_hash[:closeTime]).to be_a(String)
          expect(DateTime.parse(order_hash[:closeTime])).to be_a(DateTime)
        else
          expect(order_hash[:closeTime]).to be_nil
        end

        # Verify that nested objects are also converted to hashes
        expect(order_hash[:orderLegCollection]).to be_an(Array)
        expect(order_hash[:orderActivityCollection]).to be_an(Array)
      end
    end
  end

  describe "datetime parsing" do
    it "correctly parses ISO8601 datetime strings" do
      order_data = {
        orderId: "123456",
        status: "FILLED",
        enteredTime: "2024-01-15T14:30:45.123Z",
        closeTime: "2024-01-15T15:45:30.456Z",
        duration: "DAY",
        orderType: "LIMIT",
        complexOrderStrategyType: "NONE",
        quantity: 1,
        filledQuantity: 1,
        remainingQuantity: 0,
        price: 1.50,
        orderStrategyType: "SINGLE",
        orderLegCollection: [],
        orderActivityCollection: []
      }

      order = SchwabRb::DataObjects::Order.build(order_data)

      # Verify DateTime objects were created
      expect(order.entered_time).to be_a(DateTime)
      expect(order.close_time).to be_a(DateTime)

      # Verify correct values
      expect(order.entered_time.year).to eq(2024)
      expect(order.entered_time.month).to eq(1)
      expect(order.entered_time.day).to eq(15)
      expect(order.entered_time.hour).to eq(14)
      expect(order.entered_time.minute).to eq(30)

      expect(order.close_time.year).to eq(2024)
      expect(order.close_time.month).to eq(1)
      expect(order.close_time.day).to eq(15)
      expect(order.close_time.hour).to eq(15)
      expect(order.close_time.minute).to eq(45)
    end

    it "handles nil or empty datetime strings" do
      order_data = {
        orderId: "123456",
        status: "WORKING",
        enteredTime: nil,
        closeTime: "",
        duration: "DAY",
        orderType: "LIMIT",
        complexOrderStrategyType: "NONE",
        quantity: 1,
        filledQuantity: 0,
        remainingQuantity: 1,
        price: 1.50,
        orderStrategyType: "SINGLE",
        orderLegCollection: [],
        orderActivityCollection: []
      }

      order = SchwabRb::DataObjects::Order.build(order_data)

      # Both should be nil
      expect(order.entered_time).to be_nil
      expect(order.close_time).to be_nil
    end
  end
end

RSpec.describe SchwabRb::DataObjects::OrderActivity do
  let(:raw_data) do
    JSON.parse(File.read("spec/fixtures/orders.json"), symbolize_names: true)
        .flat_map { |order| order[:orderActivityCollection] || [] }
        .reject(&:nil?)
  end

  describe "#to_h" do
    it "converts the order activity object back to a hash with the same structure as the input data" do
      raw_data.each do |data|
        activity = SchwabRb::DataObjects::OrderActivity.build(data)
        activity_hash = activity.to_h

        expect(activity_hash[:activityType]).to eq(data[:activityType])
        expect(activity_hash[:activityId]).to eq(data[:activityId])
        expect(activity_hash[:executionType]).to eq(data[:executionType])
        expect(activity_hash[:quantity]).to eq(data[:quantity])
        expect(activity_hash[:orderRemainingQuantity]).to eq(data[:orderRemainingQuantity])

        # Check execution legs
        expect(activity_hash[:executionLegs].length).to eq(data[:executionLegs].length) if data[:executionLegs]
      end
    end
  end
end

RSpec.describe SchwabRb::DataObjects::ExecutionLeg do
  let(:raw_data) do
    JSON.parse(File.read("spec/fixtures/orders.json"), symbolize_names: true)
        .flat_map { |order| order[:orderActivityCollection] || [] }
        .flat_map { |activity| activity[:executionLegs] || [] }
        .reject(&:nil?)
  end

  describe "#to_h" do
    it "converts the execution leg object back to a hash with the same structure as the input data" do
      raw_data.each do |data|
        execution_leg = SchwabRb::DataObjects::ExecutionLeg.build(data)
        leg_hash = execution_leg.to_h

        expect(leg_hash[:legId]).to eq(data[:legId])
        expect(leg_hash[:quantity]).to eq(data[:quantity])
        expect(leg_hash[:mismarkedQuantity]).to eq(data[:mismarkedQuantity])
        expect(leg_hash[:price]).to eq(data[:price])
        expect(leg_hash[:time]).to eq(data[:time])
        expect(leg_hash[:instrumentId]).to eq(data[:instrumentId])
      end
    end
  end
end
