# frozen_string_literal: true

require "spec_helper"
require "date"

RSpec.describe SchwabRb::DataObjects::PriceHistory do
  let(:fixture_data) { JSON.parse(File.read("spec/fixtures/price_history_daily.json")) }
  let(:price_history) { described_class.build(fixture_data) }

  describe ".build" do
    it "creates a PriceHistory instance" do
      expect(price_history).to be_a(described_class)
    end
  end

  describe "#initialize" do
    it "initializes with price history data" do
      expect(price_history.symbol).to eq("SPY")
      expect(price_history.empty).to be(false)
      expect(price_history.candles).to be_an(Array)
      expect(price_history.candles.first).to be_a(SchwabRb::DataObjects::PriceHistory::Candle)
    end

    it "handles missing candles gracefully" do
      history = described_class.new({ "symbol" => "TEST", "empty" => false })
      expect(history.candles).to eq([])
      expect(history.symbol).to eq("TEST")
    end
  end

  describe "#to_h" do
    it "returns hash representation" do
      result = price_history.to_h
      expect(result).to be_a(Hash)
      expect(result).to have_key(:symbol)
      expect(result).to have_key(:empty)
      expect(result).to have_key(:candles)
      expect(result[:candles]).to be_an(Array)
    end

    it "includes all candle data" do
      result = price_history.to_h
      first_candle = result[:candles].first
      expect(first_candle).to include(
        :open, :high, :low, :close, :volume, :datetime
      )
    end
  end

  describe "#empty?" do
    it "returns false when candles exist and empty is false" do
      expect(price_history.empty?).to be(false)
    end

    it "returns true when empty is true" do
      empty_history = described_class.new({ "symbol" => "TEST", "empty" => true, "candles" => [] })
      expect(empty_history.empty?).to be(true)
    end

    it "returns true when candles array is empty" do
      empty_history = described_class.new({ "symbol" => "TEST", "empty" => false, "candles" => [] })
      expect(empty_history.empty?).to be(true)
    end
  end

  describe "#count, #size, #length" do
    it "returns the number of candles" do
      count = price_history.count
      expect(count).to be > 0
      expect(price_history.size).to eq(count)
      expect(price_history.length).to eq(count)
    end
  end

  describe "#first_candle" do
    it "returns the first candle" do
      first = price_history.first_candle
      expect(first).to be_a(SchwabRb::DataObjects::PriceHistory::Candle)
      expect(first.open).to eq(598.44)
    end

    it "returns nil for empty history" do
      empty_history = described_class.new({ "symbol" => "TEST", "empty" => true, "candles" => [] })
      expect(empty_history.first_candle).to be_nil
    end
  end

  describe "#last_candle" do
    it "returns the last candle" do
      last = price_history.last_candle
      expect(last).to be_a(SchwabRb::DataObjects::PriceHistory::Candle)
      expect(last.close).to eq(627.58)
    end

    it "returns nil for empty history" do
      empty_history = described_class.new({ "symbol" => "TEST", "empty" => true, "candles" => [] })
      expect(empty_history.last_candle).to be_nil
    end
  end

  describe "#candles_for_date_range" do
    it "filters candles by date range" do
      start_date = Date.new(2025, 7, 21)
      end_date = Date.new(2025, 7, 25)

      filtered = price_history.candles_for_date_range(start_date, end_date)
      expect(filtered).to be_an(Array)
      expect(filtered).to all(be_a(SchwabRb::DataObjects::PriceHistory::Candle))

      # Verify all candles are within the date range
      filtered.each do |candle|
        candle_date = candle.date
        expect(candle_date).to be >= start_date
        expect(candle_date).to be <= end_date
      end
    end
  end

  describe "#highest_price" do
    it "returns the highest price from all candles" do
      highest = price_history.highest_price
      expect(highest).to be_a(Float)
      expect(highest).to be > 600
    end

    it "returns nil for empty history" do
      empty_history = described_class.new({ "symbol" => "TEST", "empty" => true, "candles" => [] })
      expect(empty_history.highest_price).to be_nil
    end
  end

  describe "#lowest_price" do
    it "returns the lowest price from all candles" do
      lowest = price_history.lowest_price
      expect(lowest).to be_a(Float)
      expect(lowest).to be > 500
    end

    it "returns nil for empty history" do
      empty_history = described_class.new({ "symbol" => "TEST", "empty" => true, "candles" => [] })
      expect(empty_history.lowest_price).to be_nil
    end
  end

  describe "#highest_volume" do
    it "returns the highest volume from all candles" do
      highest_vol = price_history.highest_volume
      expect(highest_vol).to be_a(Integer)
      expect(highest_vol).to be > 0
    end

    it "returns nil for empty history" do
      empty_history = described_class.new({ "symbol" => "TEST", "empty" => true, "candles" => [] })
      expect(empty_history.highest_volume).to be_nil
    end
  end

  describe "#total_volume" do
    it "returns the sum of all volumes" do
      total = price_history.total_volume
      expect(total).to be_a(Integer)
      expect(total).to be > 0
    end

    it "returns 0 for empty history" do
      empty_history = described_class.new({ "symbol" => "TEST", "empty" => true, "candles" => [] })
      expect(empty_history.total_volume).to eq(0)
    end
  end

  describe "#average_price" do
    it "calculates the average closing price" do
      avg = price_history.average_price
      expect(avg).to be_a(Float)
      expect(avg).to be > 500
      expect(avg).to be < 700
    end

    it "returns nil for empty history" do
      empty_history = described_class.new({ "symbol" => "TEST", "empty" => true, "candles" => [] })
      expect(empty_history.average_price).to be_nil
    end
  end

  describe "#price_range" do
    it "returns hash with high, low, and range" do
      range = price_history.price_range
      expect(range).to be_a(Hash)
      expect(range).to have_key(:high)
      expect(range).to have_key(:low)
      expect(range).to have_key(:range)
      expect(range[:range]).to eq(range[:high] - range[:low])
    end

    it "returns nil for empty history" do
      empty_history = described_class.new({ "symbol" => "TEST", "empty" => true, "candles" => [] })
      expect(empty_history.price_range).to be_nil
    end
  end

  describe "#each" do
    it "iterates over candles" do
      count = 0
      price_history.each do |candle|
        expect(candle).to be_a(SchwabRb::DataObjects::PriceHistory::Candle)
        count += 1
      end
      expect(count).to eq(price_history.count)
    end

    it "returns enumerator when no block given" do
      enum = price_history.each
      expect(enum).to be_a(Enumerator)
    end
  end

  describe "Enumerable methods" do
    it "supports map" do
      closes = price_history.map(&:close)
      expect(closes).to be_an(Array)
      expect(closes.first).to be_a(Float)
    end

    it "supports select" do
      green_candles = price_history.select(&:is_green?)
      expect(green_candles).to all(satisfy(&:is_green?))
    end
  end

  describe SchwabRb::DataObjects::PriceHistory::Candle do
    let(:candle_data) do
      {
        open: 598.44,
        high: 601.22,
        low: 596.47,
        close: 597.44,
        volume: 76_605_029,
        datetime: 1_750_222_800_000
      }
    end
    let(:candle) { described_class.new(candle_data) }

    describe "#initialize" do
      it "initializes with candle data" do
        expect(candle.open).to eq(598.44)
        expect(candle.high).to eq(601.22)
        expect(candle.low).to eq(596.47)
        expect(candle.close).to eq(597.44)
        expect(candle.volume).to eq(76_605_029)
        expect(candle.datetime).to eq(1_750_222_800_000)
      end
    end

    describe "#to_h" do
      it "returns hash representation" do
        result = candle.to_h
        expect(result).to eq(candle_data)
      end
    end

    describe "#date_time" do
      it "converts datetime to Time object" do
        time = candle.date_time
        expect(time).to be_a(Time)
        expect(time.year).to eq(2025)
      end

      it "handles nil datetime" do
        candle_nil = described_class.new(candle_data.merge(datetime: nil))
        expect(candle_nil.date_time).to be_nil
      end
    end

    describe "#date" do
      it "returns Date object" do
        date = candle.date
        expect(date).to be_a(Date)
        expect(date.year).to eq(2025)
      end
    end

    describe "#price_change" do
      it "calculates price change (close - open)" do
        change = candle.price_change
        expect(change).to eq(597.44 - 598.44)
        expect(change).to be < 0
      end
    end

    describe "#price_change_percent" do
      it "calculates percentage price change" do
        percent = candle.price_change_percent
        expected = ((597.44 - 598.44) / 598.44 * 100).round(4)
        expect(percent).to eq(expected)
      end

      it "handles zero open price" do
        zero_candle = described_class.new(candle_data.merge(open: 0))
        expect(zero_candle.price_change_percent).to eq(0)
      end
    end

    describe "color predicates" do
      it "#is_green? returns true for green candle (close > open)" do
        green_candle = described_class.new(candle_data.merge(close: 600.0))
        expect(green_candle.is_green?).to be(true)
        expect(candle.is_green?).to be(false) # red candle
      end

      it "#is_red? returns true for red candle (close < open)" do
        expect(candle.is_red?).to be(true)

        green_candle = described_class.new(candle_data.merge(close: 600.0))
        expect(green_candle.is_red?).to be(false)
      end

      it "#is_doji? returns true for doji candle (close == open)" do
        doji_candle = described_class.new(candle_data.merge(close: 598.44))
        expect(doji_candle.is_doji?).to be(true)
        expect(candle.is_doji?).to be(false)
      end
    end

    describe "size calculations" do
      describe "#body_size" do
        it "calculates absolute body size" do
          body = candle.body_size
          expect(body).to eq((597.44 - 598.44).abs)
        end
      end

      describe "#wick_size" do
        it "calculates total wick size" do
          wick = candle.wick_size
          expect(wick).to eq(candle.upper_wick + candle.lower_wick)
        end
      end

      describe "#upper_wick" do
        it "calculates upper wick size" do
          upper = candle.upper_wick
          expected = 601.22 - [598.44, 597.44].max
          expect(upper).to eq(expected)
        end
      end

      describe "#lower_wick" do
        it "calculates lower wick size" do
          lower = candle.lower_wick
          expected = [598.44, 597.44].min - 596.47
          expect(lower).to eq(expected)
        end
      end
    end

    describe "technical indicators" do
      describe "#true_range" do
        it "calculates true range" do
          tr = candle.true_range
          expected = [
            601.22 - 596.47,
            (601.22 - 597.44).abs,
            (596.47 - 597.44).abs
          ].max
          expect(tr).to eq(expected)
        end
      end

      describe "#ohlc_average" do
        it "calculates OHLC average" do
          avg = candle.ohlc_average
          expected = (598.44 + 601.22 + 596.47 + 597.44) / 4.0
          expect(avg).to eq(expected)
        end
      end

      describe "#typical_price" do
        it "calculates typical price (HLC/3)" do
          typical = candle.typical_price
          expected = (601.22 + 596.47 + 597.44) / 3.0
          expect(typical).to eq(expected)
        end
      end

      describe "#weighted_price" do
        it "calculates weighted price (HLCC/4)" do
          weighted = candle.weighted_price
          expected = (601.22 + 596.47 + 597.44 + 597.44) / 4.0
          expect(weighted).to eq(expected)
        end
      end
    end
  end
end
