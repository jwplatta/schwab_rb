# frozen_string_literal: true

require "spec_helper"
require "schwab_rb/stream/client"
require "schwab_rb/stream/async_client"

RSpec.shared_examples "a stream client" do
  it "delegates subscription operations and returns itself" do
    base = instance_double(SchwabRb::Stream::Base)
    allow(SchwabRb::Stream::Base).to receive(:new).and_return(base)
    client = described_class.new(double("rest client"))
    callback = proc { |_event| }

    expect(base).to receive(:on).with(:nyse_book, symbols: nil, fields: :all, &callback)
    expect(client.on(:nyse_book, fields: :all, &callback)).to equal(client)
    expect(base).to receive(:on).with(:nyse_book, symbols: ["AAPL"], fields: nil)
    expect(client.add(:nyse_book, symbols: ["AAPL"])).to equal(client)
    expect(base).to receive(:unsub).with(:nyse_book, symbols: ["AAPL"])
    expect(client.unsub(:nyse_book, symbols: ["AAPL"])).to equal(client)
  end
end

RSpec.describe SchwabRb::Stream::Client do
  include_examples "a stream client"
end

RSpec.describe SchwabRb::Stream::AsyncClient do
  include_examples "a stream client"
end
