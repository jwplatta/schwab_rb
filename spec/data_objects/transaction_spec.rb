# frozen_string_literal: true

require "rspec"
require "schwab_rb"
require "json"

RSpec.describe SchwabRb::DataObjects::Transaction do
  let(:transaction_data) do
    JSON.parse(File.read("spec/fixtures/transaction_single.json"), symbolize_names: true)
  end

  describe ".build" do
    it "creates a transaction object from raw data" do
      transaction = SchwabRb::DataObjects::Transaction.build(transaction_data)

      expect(transaction).to be_an_instance_of(SchwabRb::DataObjects::Transaction)
      expect(transaction.activity_id).to eq(91_176_753_938)
      expect(transaction.type).to eq("TRADE")
      expect(transaction.status).to eq("VALID")
      expect(transaction.sub_account).to eq("CASH")
      expect(transaction.trade_date).to eq("2025-01-17")
      expect(transaction.order_id).to eq("1002613435352")
      expect(transaction.net_amount).to eq(-1215.95)

      # Check transfer items
      expect(transaction.transfer_items).to be_an_instance_of(Array)
      expect(transaction.transfer_items.size).to eq(2)

      # Check that all transfer items are built correctly
      transaction.transfer_items.each do |item|
        expect(item).to be_an_instance_of(SchwabRb::DataObjects::TransferItem)
        expect(item.instrument).to be_an_instance_of(SchwabRb::DataObjects::Instrument)
      end
    end
  end

  describe "#trade?" do
    it "returns true for trade transactions" do
      transaction = SchwabRb::DataObjects::Transaction.build(transaction_data)
      expect(transaction.trade?).to be true
    end
  end

  describe "#symbols" do
    it "returns an array of symbols from transfer items" do
      transaction = SchwabRb::DataObjects::Transaction.build(transaction_data)
      symbols = transaction.symbols

      expect(symbols).to be_an_instance_of(Array)
      expect(symbols).to include("MRVL  250321C00155000")
    end
  end

  describe "#asset_symbol" do
    it "returns the asset symbol from transfer items" do
      transaction = SchwabRb::DataObjects::Transaction.build(transaction_data)
      asset_symbol = transaction.asset_symbol

      expect(asset_symbol).to eq("MRVL  250321C00155000")
    end
  end
end

RSpec.describe SchwabRb::DataObjects::TransferItem do
  let(:transfer_item_data) do
    {
      instrument: {
        symbol: "MRVL  250321C00170000",
        description: "MARVELL TECHNOLOGY INC 03/21/2025 $170 Call",
        assetType: "OPTION",
        cusip: "0MRVL.CL50170000",
        putCall: "CALL",
        underlyingSymbol: "MRVL"
      },
      amount: 1.0,
      cost: 86.0,
      positionEffect: "OPENING"
    }
  end

  describe ".build" do
    it "creates a transfer item from raw data" do
      transfer_item = SchwabRb::DataObjects::TransferItem.build(transfer_item_data)

      expect(transfer_item).to be_an_instance_of(SchwabRb::DataObjects::TransferItem)
      expect(transfer_item.amount).to eq(1.0)
      expect(transfer_item.cost).to eq(86.0)
      expect(transfer_item.position_effect).to eq("OPENING")
      expect(transfer_item.fee_type).to be_nil

      # Check instrument data
      expect(transfer_item.instrument).to be_an_instance_of(SchwabRb::DataObjects::Instrument)
      expect(transfer_item.instrument.symbol).to eq("MRVL  250321C00170000")
      expect(transfer_item.instrument.description).to eq("MARVELL TECHNOLOGY INC 03/21/2025 $170 Call")
      expect(transfer_item.instrument.cusip).to eq("0MRVL.CL50170000")
      expect(transfer_item.instrument.asset_type).to eq("OPTION")
      expect(transfer_item.instrument.put_call).to eq("CALL")
      expect(transfer_item.instrument.underlying_symbol).to eq("MRVL")
    end
  end

  describe "#option?" do
    it "returns true for option instruments" do
      transfer_item = SchwabRb::DataObjects::TransferItem.build(transfer_item_data)
      expect(transfer_item.option?).to be true
    end
  end

  describe "#symbol" do
    it "returns the instrument symbol for options" do
      transfer_item = SchwabRb::DataObjects::TransferItem.build(transfer_item_data)
      expect(transfer_item.symbol).to eq("MRVL  250321C00170000")
    end
  end

  describe "#underlying_symbol" do
    it "returns the underlying symbol for options" do
      transfer_item = SchwabRb::DataObjects::TransferItem.build(transfer_item_data)
      expect(transfer_item.underlying_symbol).to eq("MRVL")
    end
  end

  describe "#put_call" do
    it "returns the put/call type for options" do
      transfer_item = SchwabRb::DataObjects::TransferItem.build(transfer_item_data)
      expect(transfer_item.put_call).to eq("CALL")
    end
  end

  describe "#fee?" do
    it "returns false when fee_type is nil" do
      transfer_item = SchwabRb::DataObjects::TransferItem.build(transfer_item_data)
      expect(transfer_item.fee?).to be false
    end

    it "returns true for fee types" do
      fee_data = transfer_item_data.merge(feeType: "OPT_REG_FEE")
      transfer_item = SchwabRb::DataObjects::TransferItem.build(fee_data)
      expect(transfer_item.fee?).to be true
    end
  end

  describe "#commission?" do
    it "returns false when fee_type is not COMMISSION" do
      transfer_item = SchwabRb::DataObjects::TransferItem.build(transfer_item_data)
      expect(transfer_item.commission?).to be false
    end

    it "returns true when fee_type is COMMISSION" do
      commission_data = transfer_item_data.merge(feeType: "COMMISSION")
      transfer_item = SchwabRb::DataObjects::TransferItem.build(commission_data)
      expect(transfer_item.commission?).to be true
    end
  end
end
