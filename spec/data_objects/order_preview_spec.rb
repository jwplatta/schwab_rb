# frozen_string_literal: true

require "spec_helper"

RSpec.describe SchwabRb::DataObjects::OrderPreview do
  let(:accepted_fixture_data) do
    JSON.parse(File.read("spec/fixtures/orders/accepted_preview.json"), symbolize_names: true)
  end

  let(:rejected_fixture_data) do
    JSON.parse(File.read("spec/fixtures/orders/rejected_preview.json"), symbolize_names: true)
  end

  let(:sample_data) do
    {
      orderId: 12_345,
      orderValue: "100.00",
      orderStrategy: {
        status: "ACCEPTED",
        price: 50.0,
        quantity: 2,
        orderType: "NET_CREDIT",
        type: "SINGLE",
        strategyId: "SINGLE",
        orderLegs: [
          {
            instruction: "BUY_TO_OPEN",
            quantity: 1,
            instrument: {
              symbol: "SPXW  250124C05900000",
              assetType: "OPTION",
              optionDeliverables: []
            }
          }
        ]
      },
      orderBalance: {
        orderValue: "100.00",
        projectedAvailableFund: "9900.00",
        projectedBuyingPower: "9900.00",
        projectedCommission: "1.00"
      },
      orderValidationResult: {
        isValid: true,
        warningMessage: "Test warning",
        rejects: [
          {
            rejectCode: "TEST_CODE",
            rejectMessage: "Test reject message"
          }
        ]
      },
      projectedCommission: {
        commission: "1.00",
        fee: "0.50",
        trueCommission: "1.50",
        commissions: [
          {
            commissionValues: [
              { value: 0.5, type: "COMMISSION" },
              { value: 0.0, type: "BASE_CHARGE" }
            ]
          },
          {
            commissionValues: [
              { value: 0.5, type: "COMMISSION" },
              { value: 0.0, type: "BASE_CHARGE" }
            ]
          }
        ],
        fees: [
          {
            feeValues: [
              { value: 0.25, type: "OPT_REG_FEE" }
            ]
          },
          {
            feeValues: [
              { value: 0.25, type: "INDEX_OPTION_FEE" }
            ]
          }
        ]
      }
    }
  end

  let(:order_preview) { described_class.new(sample_data) }

  describe "#initialize" do
    it "creates an OrderPreview instance with correct attributes" do
      expect(order_preview.order_id).to eq(12_345)
      expect(order_preview.order_value).to eq("100.00")
      expect(order_preview.order_strategy).to be_a(SchwabRb::DataObjects::OrderPreview::OrderStrategy)
      expect(order_preview.order_balance).to be_a(SchwabRb::DataObjects::OrderPreview::OrderBalance)
      expect(order_preview.order_validation_result).to be_a(SchwabRb::DataObjects::OrderPreview::OrderValidationResult)
      expect(order_preview.projected_commission).to be_a(SchwabRb::DataObjects::OrderPreview::CommissionAndFee)
    end
  end

  describe "convenience methods" do
    it "provides status from order strategy" do
      expect(order_preview.status).to eq("ACCEPTED")
    end

    it "provides price from order strategy" do
      expect(order_preview.price).to eq(50.0)
    end

    it "provides quantity from order strategy" do
      expect(order_preview.quantity).to eq(2)
    end

    it "indicates if order is accepted" do
      expect(order_preview.accepted?).to be true
    end

    it "calculates commission correctly" do
      expect(order_preview.commission).to eq(1.0) # 0.5 + 0.5 from COMMISSION values
    end

    it "provides fees" do
      expect(order_preview.fees).to eq(0.5) # 0.25 + 0.25 from fee values
    end
  end

  describe ".build" do
    it "creates an OrderPreview instance using the build class method" do
      built_preview = described_class.build(sample_data)
      expect(built_preview).to be_a(SchwabRb::DataObjects::OrderPreview)
      expect(built_preview.order_value).to eq("100.00")
      expect(built_preview.order_strategy).to be_a(SchwabRb::DataObjects::OrderPreview::OrderStrategy)
    end
  end

  describe "#to_h" do
    it "converts the OrderPreview to a hash" do
      hash = order_preview.to_h

      expect(hash).to be_a(Hash)
      expect(hash[:orderValue]).to eq("100.00")
      expect(hash[:orderStrategy]).to be_a(Hash)
      expect(hash[:orderBalance]).to be_a(Hash)
      expect(hash[:orderValidationResult]).to be_a(Hash)
      expect(hash[:projectedCommission]).to be_a(Hash)
    end

    it "includes nested object hashes" do
      hash = order_preview.to_h

      # Test OrderStrategy
      expect(hash[:orderStrategy][:status]).to eq("ACCEPTED")
      expect(hash[:orderStrategy][:price]).to eq(50.0)
      expect(hash[:orderStrategy][:quantity]).to eq(2)
      expect(hash[:orderStrategy][:orderType]).to eq("NET_CREDIT")
      expect(hash[:orderStrategy][:type]).to eq("SINGLE")
      expect(hash[:orderStrategy][:strategyId]).to eq("SINGLE")
      expect(hash[:orderStrategy][:orderLegs]).to be_an(Array)
      expect(hash[:orderStrategy][:orderLegs].first[:instruction]).to eq("BUY_TO_OPEN")

      # Test OrderBalance
      expect(hash[:orderBalance][:orderValue]).to eq("100.00")
      expect(hash[:orderBalance][:projectedAvailableFund]).to eq("9900.00")
      expect(hash[:orderBalance][:projectedBuyingPower]).to eq("9900.00")
      expect(hash[:orderBalance][:projectedCommission]).to eq("1.00")

      # Test OrderValidationResult
      expect(hash[:orderValidationResult][:isValid]).to eq(true)
      expect(hash[:orderValidationResult][:warningMessage]).to eq("Test warning")
      expect(hash[:orderValidationResult][:rejects]).to be_an(Array)
      expect(hash[:orderValidationResult][:rejects].first[:rejectCode]).to eq("TEST_CODE")

      # Test CommissionAndFee
      expect(hash[:projectedCommission][:commission]).to eq(1.0)
      expect(hash[:projectedCommission][:fee]).to eq(0.5)
      expect(hash[:projectedCommission][:trueCommission]).to eq(1.5)
      expect(hash[:projectedCommission][:commissions]).to be_an(Array)
      expect(hash[:projectedCommission][:fees]).to be_an(Array)
    end
  end

  describe "nested classes" do
    describe "OrderStrategy" do
      let(:order_strategy) { order_preview.order_strategy }

      it "has correct attributes" do
        expect(order_strategy.status).to eq("ACCEPTED")
        expect(order_strategy.price).to eq(50.0)
        expect(order_strategy.quantity).to eq(2)
        expect(order_strategy.order_type).to eq("NET_CREDIT")
        expect(order_strategy.type).to eq("SINGLE")
        expect(order_strategy.strategy_id).to eq("SINGLE")
        expect(order_strategy.order_legs).to be_an(Array)
        expect(order_strategy.order_legs.size).to eq(1)
      end

      it "converts to hash correctly" do
        hash = order_strategy.to_h
        expect(hash[:status]).to eq("ACCEPTED")
        expect(hash[:price]).to eq(50.0)
        expect(hash[:quantity]).to eq(2)
        expect(hash[:orderType]).to eq("NET_CREDIT")
        expect(hash[:type]).to eq("SINGLE")
        expect(hash[:strategyId]).to eq("SINGLE")
        expect(hash[:orderLegs]).to be_an(Array)
      end
    end

    describe "OrderBalance" do
      let(:order_balance) { order_preview.order_balance }

      it "has correct attributes" do
        expect(order_balance.order_value).to eq("100.00")
        expect(order_balance.projected_available_fund).to eq("9900.00")
        expect(order_balance.projected_buying_power).to eq("9900.00")
        expect(order_balance.projected_commission).to eq("1.00")
      end

      it "converts to hash correctly" do
        hash = order_balance.to_h
        expect(hash[:orderValue]).to eq("100.00")
        expect(hash[:projectedAvailableFund]).to eq("9900.00")
        expect(hash[:projectedBuyingPower]).to eq("9900.00")
        expect(hash[:projectedCommission]).to eq("1.00")
      end
    end

    describe "OrderValidationResult" do
      let(:validation_result) { order_preview.order_validation_result }

      it "has correct attributes" do
        expect(validation_result.is_valid).to eq(true)
        expect(validation_result.warning_message).to eq("Test warning")
        expect(validation_result.rejects).to be_an(Array)
        expect(validation_result.rejects.size).to eq(1)
      end

      it "converts to hash correctly" do
        hash = validation_result.to_h
        expect(hash[:isValid]).to eq(true)
        expect(hash[:warningMessage]).to eq("Test warning")
        expect(hash[:rejects]).to be_an(Array)
      end
    end

    describe "CommissionAndFee" do
      let(:commission_and_fee) { order_preview.projected_commission }

      it "has correct attributes" do
        expect(commission_and_fee.commission).to eq(1.0)
        expect(commission_and_fee.fee).to eq(0.5)
        expect(commission_and_fee.true_commission).to eq(1.5)
        expect(commission_and_fee.commissions).to be_an(Array)
        expect(commission_and_fee.fees).to be_an(Array)
      end

      it "converts to hash correctly" do
        hash = commission_and_fee.to_h
        expect(hash[:commission]).to eq(1.0)
        expect(hash[:fee]).to eq(0.5)
        expect(hash[:trueCommission]).to eq(1.5)
        expect(hash[:commissions]).to be_an(Array)
        expect(hash[:fees]).to be_an(Array)
      end
    end
  end

  describe "edge cases" do
    context "with minimal data" do
      let(:minimal_data) { { orderValue: "50.00" } }
      let(:minimal_preview) { described_class.new(minimal_data) }

      it "handles missing nested objects gracefully" do
        expect(minimal_preview.order_value).to eq("50.00")
        expect(minimal_preview.order_strategy).to be_nil
        expect(minimal_preview.order_balance).to be_nil
        expect(minimal_preview.order_validation_result).to be_nil
        expect(minimal_preview.projected_commission).to be_nil
      end

      it "converts to hash with only available data" do
        hash = minimal_preview.to_h
        expect(hash[:orderValue]).to eq("50.00")
        expect(hash[:orderStrategy]).to be_nil
        expect(hash[:orderBalance]).to be_nil
        expect(hash[:orderValidationResult]).to be_nil
        expect(hash[:projectedCommission]).to be_nil
      end
    end

    context "with nil values" do
      let(:nil_data) { { orderValue: nil } }
      let(:nil_preview) { described_class.new(nil_data) }

      it "handles nil values correctly" do
        expect(nil_preview.order_value).to be_nil
      end

      it "includes nil values in hash" do
        hash = nil_preview.to_h
        expect(hash[:orderValue]).to be_nil
      end
    end
  end

  describe "with fixture data" do
    context "using accepted_preview fixture" do
      let(:accepted_preview) { described_class.new(accepted_fixture_data) }

      it "parses accepted fixture data correctly" do
        expect(accepted_preview.order_id).to eq(0)
        expect(accepted_preview.status).to eq("ACCEPTED")
        expect(accepted_preview.price).to eq(1.25)
        expect(accepted_preview.quantity).to eq(1.0)
        expect(accepted_preview.accepted?).to be true
      end

      it "handles commission data from fixture correctly" do
        expect(accepted_preview.commission).to eq(2.60)
        expect(accepted_preview.fees).to eq(2.10)
        expect(accepted_preview.projected_commission.true_commission).to eq(5.2)
      end

      it "parses order legs correctly" do
        expect(accepted_preview.order_strategy.order_legs.length).to eq(4)
        first_leg = accepted_preview.order_strategy.order_legs[0]
        expect(first_leg.instruction).to eq("SELL_TO_OPEN")
        expect(first_leg.instrument.symbol).to eq("SPXW  250725P05680000")
      end

      it "handles validation result correctly" do
        expect(accepted_preview.order_validation_result.rejects).to be_empty
      end
    end

    context "using rejected_preview fixture" do
      let(:rejected_preview) { described_class.new(rejected_fixture_data) }

      it "parses rejected fixture data correctly" do
        expect(rejected_preview.order_id).to eq(0)
        expect(rejected_preview.status).to eq("REJECTED")
        expect(rejected_preview.price).to eq(3.46)
        expect(rejected_preview.quantity).to eq(1.0)
        expect(rejected_preview.accepted?).to be false
      end

      it "handles commission data from fixture correctly" do
        expect(rejected_preview.commission).to eq(2.60)
        expect(rejected_preview.fees).to eq(2.10)
        expect(rejected_preview.projected_commission.true_commission).to eq(5.2)
      end

      it "handles validation result with rejects" do
        expect(rejected_preview.order_validation_result.rejects.length).to eq(1)
        reject = rejected_preview.order_validation_result.rejects[0]
        expect(reject.reject_code).to be_nil
        expect(reject.reject_message).to be_nil
      end
    end

    context "commission calculation from fixture data" do
      let(:accepted_preview) { described_class.new(accepted_fixture_data) }

      it "calculates commission from detailed legs correctly" do
        commission_from_legs = accepted_preview.projected_commission.commission_total
        # Should be 4 legs * 0.65 COMMISSION each = 2.60
        expect(commission_from_legs).to eq(2.60)
      end

      it "calculates fees from detailed legs correctly" do
        fee_from_legs = accepted_preview.projected_commission.fee_total
        # Should be (0.01 + 0.47) * 2 + (0.01 + 0.56) * 2 = 0.96 + 1.14 = 2.10
        expect(fee_from_legs).to eq(2.10)
      end
    end
  end
end
