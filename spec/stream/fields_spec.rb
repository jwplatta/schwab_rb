# frozen_string_literal: true

require "spec_helper"
require "schwab_rb/stream/fields"

RSpec.describe SchwabRb::Stream::Fields do
  describe "LevelOneEquity" do
    it "defines expected field constants" do
      expect(SchwabRb::Stream::Fields::LevelOneEquity::SYMBOL).to eq(0)
      expect(SchwabRb::Stream::Fields::LevelOneEquity::BID_PRICE).to eq(1)
      expect(SchwabRb::Stream::Fields::LevelOneEquity::ASK_PRICE).to eq(2)
      expect(SchwabRb::Stream::Fields::LevelOneEquity::LAST_PRICE).to eq(3)
      expect(SchwabRb::Stream::Fields::LevelOneEquity::MARK).to eq(33)
      expect(SchwabRb::Stream::Fields::LevelOneEquity::POST_MARKET_NET_CHANGE_PERCENT).to eq(51)
    end

    it "provides ALL constant with all field values" do
      expect(SchwabRb::Stream::Fields::LevelOneEquity::ALL).to eq((0..51).to_a)
      expect(SchwabRb::Stream::Fields::LevelOneEquity::ALL).to be_frozen
    end
  end

  describe "LevelOneOption" do
    it "has 56 fields" do
      expect(SchwabRb::Stream::Fields::LevelOneOption::ALL.length).to eq(56)
    end
  end

  describe "Book" do
    it "defines order book fields" do
      expect(SchwabRb::Stream::Fields::Book::SYMBOL).to eq(0)
      expect(SchwabRb::Stream::Fields::Book::BOOK_TIME).to eq(1)
      expect(SchwabRb::Stream::Fields::Book::BIDS).to eq(2)
      expect(SchwabRb::Stream::Fields::Book::ASKS).to eq(3)
    end

    it "provides ALL constant" do
      expect(SchwabRb::Stream::Fields::Book::ALL).to eq([0, 1, 2, 3])
    end
  end

  describe "BookBid" do
    it "defines bid fields" do
      expect(SchwabRb::Stream::Fields::BookBid::BID_PRICE).to eq(0)
      expect(SchwabRb::Stream::Fields::BookBid::TOTAL_VOLUME).to eq(1)
      expect(SchwabRb::Stream::Fields::BookBid::NUM_BIDS).to eq(2)
      expect(SchwabRb::Stream::Fields::BookBid::BIDS).to eq(3)
    end
  end

  describe "BookExchange" do
    it "defines per-exchange fields" do
      expect(SchwabRb::Stream::Fields::BookExchange::EXCHANGE).to eq(0)
      expect(SchwabRb::Stream::Fields::BookExchange::VOLUME).to eq(1)
      expect(SchwabRb::Stream::Fields::BookExchange::SEQUENCE).to eq(2)
    end
  end

  describe "SERVICE_FIELDS mapping" do
    it "maps all services to their field modules" do
      expect(SchwabRb::Stream::Fields::SERVICE_FIELDS["LEVELONE_EQUITIES"]).to eq(SchwabRb::Stream::Fields::LevelOneEquity)
      expect(SchwabRb::Stream::Fields::SERVICE_FIELDS["NYSE_BOOK"]).to eq(SchwabRb::Stream::Fields::Book)
      expect(SchwabRb::Stream::Fields::SERVICE_FIELDS["NASDAQ_BOOK"]).to eq(SchwabRb::Stream::Fields::Book)
      expect(SchwabRb::Stream::Fields::SERVICE_FIELDS["OPTIONS_BOOK"]).to eq(SchwabRb::Stream::Fields::Book)
      expect(SchwabRb::Stream::Fields::SERVICE_FIELDS["ACCT_ACTIVITY"]).to eq(SchwabRb::Stream::Fields::AccountActivity)
    end
  end

  describe ".resolve" do
    it "returns ALL fields when passed :all" do
      result = described_class.resolve("NYSE_BOOK", :all)
      expect(result).to eq([0, 1, 2, 3])
    end

    it "converts field values to integers" do
      result = described_class.resolve("LEVELONE_EQUITIES", [1, 2, 3])
      expect(result).to eq([1, 2, 3])
    end

    it "wraps a single field in an array" do
      result = described_class.resolve("NYSE_BOOK", 0)
      expect(result).to eq([0])
    end
  end
end
