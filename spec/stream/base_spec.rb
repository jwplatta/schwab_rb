# frozen_string_literal: true

require "spec_helper"
require "schwab_rb/stream/base"

RSpec.describe SchwabRb::Stream::Base do
  let(:streamer_info) do
    instance_double(
      SchwabRb::DataObjects::UserPreferences::StreamerInfo,
      streamer_socket_url: "wss://streamer.schwab.com/ws",
      schwab_client_customer_id: "customer123",
      schwab_client_correl_id: "correl456",
      schwab_client_channel: "channel1",
      schwab_client_function_id: "func1"
    )
  end

  let(:user_preferences) do
    instance_double(
      SchwabRb::DataObjects::UserPreferences,
      streamer_info: [streamer_info]
    )
  end

  let(:token) do
    instance_double(SchwabRb::Auth::Token, token: "test_access_token")
  end

  let(:token_manager) do
    instance_double(SchwabRb::Auth::TokenManager, token: token)
  end

  let(:session) do
    instance_double(OAuth2::AccessToken, expired?: false)
  end

  let(:rest_client) do
    instance_double(
      SchwabRb::Client,
      get_user_preferences: user_preferences,
      token_manager: token_manager,
      session: session,
      refresh!: nil
    )
  end

  subject(:stream) { described_class.new(rest_client) }

  describe "#on" do
    it "registers a handler for a service" do
      events = []
      stream.on(:nyse_book, symbols: ["AAPL"], fields: :all) { |e| events << e }

      handlers = stream.instance_variable_get(:@handlers)
      expect(handlers).to have_key("NYSE_BOOK")
      expect(handlers["NYSE_BOOK"].length).to eq(1)
      expect(handlers["NYSE_BOOK"][0][:symbols]).to eq(["AAPL"])
    end

    it "resolves :all fields to the appropriate field list" do
      stream.on(:nyse_book, symbols: ["AAPL"], fields: :all) { |_e| }

      subscriptions = stream.instance_variable_get(:@subscriptions)
      expect(subscriptions["NYSE_BOOK"][:fields]).to eq([0, 1, 2, 3])
    end

    it "accepts specific field constants" do
      stream.on(:level_one_equities, symbols: ["AAPL"], fields: [
        SchwabRb::Stream::Fields::LevelOneEquity::BID_PRICE,
        SchwabRb::Stream::Fields::LevelOneEquity::ASK_PRICE
      ]) { |_e| }

      subscriptions = stream.instance_variable_get(:@subscriptions)
      expect(subscriptions["LEVELONE_EQUITIES"][:fields]).to eq([1, 2])
    end

    it "raises for unknown service symbols" do
      expect {
        stream.on(:unknown_service, symbols: ["AAPL"]) { |_e| }
      }.to raise_error(ArgumentError, /Unknown service/)
    end

    it "supports multiple handlers for the same service" do
      stream.on(:nyse_book, symbols: ["AAPL"], fields: :all) { |_e| }
      stream.on(:nyse_book, symbols: ["MSFT"], fields: :all) { |_e| }

      handlers = stream.instance_variable_get(:@handlers)
      expect(handlers["NYSE_BOOK"].length).to eq(2)
    end

    it "merges subscriptions for the same service" do
      stream.on(:nyse_book, symbols: ["AAPL"], fields: :all) { |_e| }
      stream.on(:nyse_book, symbols: ["MSFT"], fields: :all) { |_e| }

      subscriptions = stream.instance_variable_get(:@subscriptions)
      expect(subscriptions["NYSE_BOOK"][:symbols]).to contain_exactly("AAPL", "MSFT")
    end

    it "returns self for chaining" do
      result = stream.on(:nyse_book, symbols: ["AAPL"], fields: :all) { |_e| }
      expect(result).to eq(stream)
    end
  end

  describe "#dispatch_message" do
    it "dispatches data messages to registered handlers" do
      events = []
      stream.on(:nyse_book, symbols: ["AAPL"], fields: :all) { |e| events << e }

      message = {
        "data" => [
          { "service" => "NYSE_BOOK", "content" => [{ "key" => "AAPL" }] }
        ]
      }

      stream.send(:dispatch_message, message)

      expect(events.length).to eq(1)
      expect(events[0]["service"]).to eq("NYSE_BOOK")
    end

    it "ignores data for services with no handlers" do
      events = []
      stream.on(:nyse_book, symbols: ["AAPL"], fields: :all) { |e| events << e }

      message = {
        "data" => [
          { "service" => "NASDAQ_BOOK", "content" => [{ "key" => "AMD" }] }
        ]
      }

      stream.send(:dispatch_message, message)

      expect(events).to be_empty
    end

    it "dispatches to multiple handlers for the same service" do
      events1 = []
      events2 = []

      stream.on(:nyse_book, symbols: ["AAPL"], fields: :all) { |e| events1 << e }
      stream.on(:nyse_book, symbols: ["MSFT"], fields: :all) { |e| events2 << e }

      message = {
        "data" => [
          { "service" => "NYSE_BOOK", "content" => [{ "key" => "AAPL" }] }
        ]
      }

      stream.send(:dispatch_message, message)

      expect(events1.length).to eq(1)
      expect(events2.length).to eq(1)
    end
  end

  describe "reconnection logic" do
    it "does not reconnect if connection lived less than MIN_CONNECTION_TIME" do
      stream.instance_variable_set(:@should_run, true)
      stream.instance_variable_set(:@connect_time, Time.now - 30)

      expect(stream.send(:should_reconnect?)).to be false
    end

    it "reconnects if connection lived longer than MIN_CONNECTION_TIME" do
      stream.instance_variable_set(:@should_run, true)
      stream.instance_variable_set(:@connect_time, Time.now - 120)

      expect(stream.send(:should_reconnect?)).to be true
    end

    it "does not reconnect if should_run is false" do
      stream.instance_variable_set(:@should_run, false)
      stream.instance_variable_set(:@connect_time, Time.now - 120)

      expect(stream.send(:should_reconnect?)).to be false
    end

    it "does not reconnect if connect_time is nil" do
      stream.instance_variable_set(:@should_run, true)

      expect(stream.send(:should_reconnect?)).to be false
    end
  end

  describe "subscription merging" do
    it "merges symbols from multiple handlers" do
      result = stream.send(:merge_subscription,
        { symbols: ["AAPL"], fields: [0, 1] },
        { symbols: ["MSFT"], fields: [0, 2], callback: nil }
      )

      expect(result[:symbols]).to contain_exactly("AAPL", "MSFT")
      expect(result[:fields]).to contain_exactly(0, 1, 2)
    end

    it "deduplicates symbols" do
      result = stream.send(:merge_subscription,
        { symbols: ["AAPL"], fields: [0, 1] },
        { symbols: ["AAPL"], fields: [0, 2], callback: nil }
      )

      expect(result[:symbols]).to eq(["AAPL"])
    end

    it "creates a new subscription when none exists" do
      result = stream.send(:merge_subscription,
        nil,
        { symbols: ["AAPL"], fields: [0, 1], callback: nil }
      )

      expect(result[:symbols]).to eq(["AAPL"])
      expect(result[:fields]).to eq([0, 1])
    end
  end

  describe "#unsub" do
    before do
      stream.on(:nyse_book, symbols: %w[AAPL MSFT], fields: :all) { |_e| }
      stream.on(:level_one_equities, symbols: %w[SPY QQQ], fields: :all) { |_e| }
    end

    it "removes specified symbols from subscriptions" do
      stream.unsub(:nyse_book, symbols: ["AAPL"])

      subscriptions = stream.instance_variable_get(:@subscriptions)
      expect(subscriptions["NYSE_BOOK"][:symbols]).to eq(["MSFT"])
      expect(subscriptions["LEVELONE_EQUITIES"][:symbols]).to eq(%w[SPY QQQ])
    end

    it "removes the service entirely from subscriptions when no symbols remain" do
      stream.unsub(:nyse_book, symbols: %w[AAPL MSFT])

      subscriptions = stream.instance_variable_get(:@subscriptions)
      expect(subscriptions).not_to have_key("NYSE_BOOK")
      expect(subscriptions).to have_key("LEVELONE_EQUITIES")
    end

    it "removes symbols from handlers and purges empty handlers" do
      stream.unsub(:nyse_book, symbols: ["AAPL"])

      handlers = stream.instance_variable_get(:@handlers)
      expect(handlers["NYSE_BOOK"].length).to eq(1)
      expect(handlers["NYSE_BOOK"].first[:symbols]).to eq(["MSFT"])

      stream.unsub(:nyse_book, symbols: ["MSFT"])
      expect(handlers).not_to have_key("NYSE_BOOK")
    end

    it "sends an UNSUBS message when connected" do
      connection = double("connection", write: nil, flush: nil)
      stream.instance_variable_set(:@connection, connection)
      stream.instance_variable_set(:@connected, true)
      stream.instance_variable_set(
        :@message_builder,
        SchwabRb::Stream::MessageBuilder.new("cust1", "correl1")
      )

      expect(connection).to receive(:write) do |payload|
        parsed = JSON.parse(payload)
        req = parsed["requests"].first
        expect(req["service"]).to eq("NYSE_BOOK")
        expect(req["command"]).to eq("UNSUBS")
        expect(req["parameters"]["keys"]).to eq("AAPL")
      end

      stream.unsub(:nyse_book, symbols: ["AAPL"])
    end

    it "returns self for chaining" do
      expect(stream.unsub(:nyse_book, symbols: ["AAPL"])).to eq(stream)
    end
  end

  describe "#run_receive_loop" do
    it "raises when connection.read returns nil" do
      connection = double("connection")
      allow(connection).to receive(:read).and_return(nil)
      stream.instance_variable_set(:@connection, connection)
      stream.instance_variable_set(:@connected, true)
      stream.instance_variable_set(:@should_run, true)

      expect {
        stream.send(:run_receive_loop)
      }.to raise_error(RuntimeError, /Connection closed by remote host/)
    end
  end
end
