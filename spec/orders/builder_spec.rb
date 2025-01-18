require "spec_helper"

describe SchwabRb::Orders::Builder do
  let(:builder) { SchwabRb::Orders::Builder.new }

  describe "#set_session" do
    it "sets the session" do
      builder.set_session(SchwabRb::Orders::Session::NORMAL)
      expect(builder.instance_variable_get(:@session)).to eq(SchwabRb::Orders::Session::NORMAL)
    end
  end

  describe "#clear_session" do
    it "clears the session" do
      builder.set_session(SchwabRb::Orders::Session::NORMAL)
      builder.clear_session
      expect(builder.instance_variable_get(:@session)).to be_nil
    end
  end

  describe "#set_duration" do
    it "sets the duration" do
      builder.set_duration(SchwabRb::Orders::Duration::DAY)
      expect(builder.instance_variable_get(:@duration)).to eq(SchwabRb::Orders::Duration::DAY)
    end
  end

  describe "#clear_duration" do
    it "clears the duration" do
      builder.set_duration(SchwabRb::Orders::Duration::DAY)
      builder.clear_duration
      expect(builder.instance_variable_get(:@duration)).to be_nil
    end
  end

  describe "#set_order_type" do
    it "sets the order type" do
      builder.set_order_type(SchwabRb::Order::Types::MARKET)
      expect(builder.instance_variable_get(:@order_type)).to eq(SchwabRb::Order::Types::MARKET)
    end
  end

  describe "#clear_order_type" do
    it "clears the order type" do
      builder.set_order_type(SchwabRb::Order::Types::MARKET)
      builder.clear_order_type
      expect(builder.instance_variable_get(:@order_type)).to be_nil
    end
  end

  describe "#set_quantity" do
    it "sets the quantity" do
      builder.set_quantity(100)
      expect(builder.instance_variable_get(:@quantity)).to eq(100)
    end

    it "raises an error if quantity is not positive" do
      expect { builder.set_quantity(0) }.to raise_error("quantity must be positive")
    end
  end

  describe "#clear_quantity" do
    it "clears the quantity" do
      builder.set_quantity(100)
      builder.clear_quantity
      expect(builder.instance_variable_get(:@quantity)).to be_nil
    end
  end

  describe "#set_stop_price" do
    it "sets the stop price" do
      builder.set_stop_price(100.50)
      expect(builder.instance_variable_get(:@stop_price)).to eq("100.50")
    end
  end

  describe "#clear_stop_price" do
    it "clears the stop price" do
      builder.set_stop_price(100.50)
      builder.clear_stop_price
      expect(builder.instance_variable_get(:@stop_price)).to be_nil
    end
  end

  describe "#add_child_order_strategy" do
    it "adds a child order strategy" do
      child_builder = SchwabRb::Orders::Builder.new
      builder.add_child_order_strategy(child_builder)
      expect(builder.instance_variable_get(:@child_order_strategies)).to include(child_builder)
    end

    it "raises an error if child order strategy is not valid" do
      expect { builder.add_child_order_strategy("invalid") }.to raise_error("child order must be OrderBuilder or Hash")
    end
  end

  describe "#clear_child_order_strategies" do
    it "clears the child order strategies" do
      child_builder = SchwabRb::Orders::Builder.new
      builder.add_child_order_strategy(child_builder)
      builder.clear_child_order_strategies
      expect(builder.instance_variable_get(:@child_order_strategies)).to be_nil
    end
  end

  describe "#add_equity_leg" do
    it "adds an equity leg" do
      builder.add_equity_leg(SchwabRb::Orders::EquityInstructions::BUY, "AAPL", 10)
      expect(builder.instance_variable_get(:@order_leg_collection).first[:instruction]).to eq(SchwabRb::Orders::EquityInstructions::BUY)
    end

    it "raises an error if quantity is not positive" do
      expect { builder.add_equity_leg(SchwabRb::Orders::EquityInstructions::BUY, "AAPL", 0) }.to raise_error("quantity must be positive")
    end
  end

  describe "#clear_order_legs" do
    it "clears the order legs" do
      builder.add_equity_leg(SchwabRb::Orders::EquityInstructions::BUY, "AAPL", 10)
      builder.clear_order_legs
      expect(builder.instance_variable_get(:@order_leg_collection)).to be_nil
    end
  end

  describe "#build" do
    it "builds the order" do
      builder.set_session(SchwabRb::Orders::Session::NORMAL)
      builder.set_duration(SchwabRb::Orders::Duration::DAY)
      builder.set_order_type(SchwabRb::Order::Types::MARKET)
      builder.set_quantity(100)
      builder.set_stop_price(100.50)
      builder.add_equity_leg(SchwabRb::Orders::EquityInstructions::BUY, "AAPL", 10)
      order = builder.build
      expect(order["session"]).to eq(SchwabRb::Orders::Session::NORMAL)
      expect(order["duration"]).to eq(SchwabRb::Orders::Duration::DAY)
      expect(order["order_type"]).to eq(SchwabRb::Order::Types::MARKET)
      expect(order["quantity"]).to eq(100)
      expect(order["stop_price"]).to eq("100.50")
      expect(order["order_leg_collection"].first[:instruction]).to eq(SchwabRb::Orders::EquityInstructions::BUY)
      expect(order["order_leg_collection"].first[:instrument]["asset_type"]).to eq("EQUITY")
    end
  end
end
