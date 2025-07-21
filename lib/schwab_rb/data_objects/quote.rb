# frozen_string_literal: true

module SchwabRb
  module DataObjects
    class QuoteFactory
      def self.build(quote_data)
        # Extract the data from nested structure (symbol is the key)
        symbol = quote_data.keys.first
        data = quote_data[symbol]
        data[:symbol] ||= symbol

        case data[:assetMainType]
        when "OPTION"
          OptionQuote.new(data)
        when "INDEX"
          IndexQuote.new(data)
        when "EQUITY"
          EquityQuote.new(data)
        else
          raise "Unknown assetMainType: #{data[:assetMainType]}"
        end
      end
    end

    class OptionQuote
      attr_reader :symbol, :asset_main_type, :realtime, :ssid, :quote_52_week_high, :quote_52_week_low, :ask_price,
                  :ask_size, :bid_price, :bid_size, :close_price, :delta, :gamma, :high_price, :ind_ask_price, :ind_bid_price, :ind_time, :implied_yield, :last_price, :last_size, :low_price, :mark, :mark_change, :mark_percent_change, :money_intrinsic_value, :net_change, :net_percent_change, :open_interest, :open_price, :time, :rho, :security_status, :theoretical_option_value, :theta, :time_value, :total_volume, :trade_time, :underlying_price, :vega, :volatility, :contract_type, :days_to_expiration, :deliverables, :description, :exchange, :exchange_name, :exercise_type, :expiration_day, :expiration_month, :expiration_type, :expiration_year, :is_penny_pilot, :last_trading_day, :multiplier, :settlement_type, :strike_price, :underlying, :underlying_asset_type

      def initialize(data)
        @symbol = data[:symbol]
        @asset_main_type = data[:assetMainType]
        @realtime = data[:realtime]
        @ssid = data[:ssid]
        @quote_52_week_high = data.dig(:quote, :"52WeekHigh")
        @quote_52_week_low = data.dig(:quote, :"52WeekLow")
        @ask_price = data.dig(:quote, :askPrice)
        @ask_size = data.dig(:quote, :askSize)
        @bid_price = data.dig(:quote, :bidPrice)
        @bid_size = data.dig(:quote, :bidSize)
        @close_price = data.dig(:quote, :closePrice)
        @delta = data.dig(:quote, :delta)
        @gamma = data.dig(:quote, :gamma)
        @high_price = data.dig(:quote, :highPrice)
        @ind_ask_price = data.dig(:quote, :indAskPrice)
        @ind_bid_price = data.dig(:quote, :indBidPrice)
        @ind_quote_time = data.dig(:quote, :indQuoteTime)
        @implied_yield = data.dig(:quote, :impliedYield)
        @last_price = data.dig(:quote, :lastPrice)
        @last_size = data.dig(:quote, :lastSize)
        @low_price = data.dig(:quote, :lowPrice)
        @mark = data.dig(:quote, :mark)
        @mark_change = data.dig(:quote, :markChange)
        @mark_percent_change = data.dig(:quote, :markPercentChange)
        @money_intrinsic_value = data.dig(:quote, :moneyIntrinsicValue)
        @net_change = data.dig(:quote, :netChange)
        @net_percent_change = data.dig(:quote, :netPercentChange)
        @open_interest = data.dig(:quote, :openInterest)
        @open_price = data.dig(:quote, :openPrice)
        @quote_time = data.dig(:quote, :quoteTime)
        @rho = data.dig(:quote, :rho)
        @security_status = data.dig(:quote, :securityStatus)
        @theoretical_option_value = data.dig(:quote, :theoreticalOptionValue)
        @theta = data.dig(:quote, :theta)
        @time_value = data.dig(:quote, :timeValue)
        @total_volume = data.dig(:quote, :totalVolume)
        @trade_time = data.dig(:quote, :tradeTime)
        @underlying_price = data.dig(:quote, :underlyingPrice)
        @vega = data.dig(:quote, :vega)
        @volatility = data.dig(:quote, :volatility)
        @contract_type = data.dig(:reference, :contractType)
        @days_to_expiration = data.dig(:reference, :daysToExpiration)
        @deliverables = data.dig(:reference, :deliverables)
        @description = data.dig(:reference, :description)
        @exchange = data.dig(:reference, :exchange)
        @exchange_name = data.dig(:reference, :exchangeName)
        @exercise_type = data.dig(:reference, :exerciseType)
        @expiration_day = data.dig(:reference, :expirationDay)
        @expiration_month = data.dig(:reference, :expirationMonth)
        @expiration_type = data.dig(:reference, :expirationType)
        @expiration_year = data.dig(:reference, :expirationYear)
        @is_penny_pilot = data.dig(:reference, :isPennyPilot)
        @last_trading_day = data.dig(:reference, :lastTradingDay)
        @multiplier = data.dig(:reference, :multiplier)
        @settlement_type = data.dig(:reference, :settlementType)
        @strike_price = data.dig(:reference, :strikePrice)
        @underlying = data.dig(:reference, :underlying)
        @underlying_asset_type = data.dig(:reference, :underlyingAssetType)
      end

      def zone
        if quote_delta.abs > 0.3
          "DANGER"
        elsif quote_delta.abs > 0.15
          "AT_RISK"
        else
          "SAFE"
        end
      end
    end

    class IndexQuote
      attr_reader :symbol, :asset_main_type, :realtime, :ssid, :avg_10_days_volume, :avg_1_year_volume, :div_amount,
                  :div_freq, :div_pay_amount, :div_yield, :eps, :fund_leverage_factor, :pe_ratio, :quote_52_week_high, :quote_52_week_low, :close_price, :high_price, :last_price, :low_price, :net_change, :net_percent_change, :open_price, :security_status, :total_volume, :trade_time, :description, :exchange, :exchange_name

      def initialize(data)
        @symbol = data[:symbol]
        @asset_main_type = data[:assetMainType]
        @realtime = data[:realtime]
        @ssid = data[:ssid]
        @avg_10_days_volume = data.dig(:fundamental, :avg10DaysVolume)
        @avg_1_year_volume = data.dig(:fundamental, :avg1YearVolume)
        @div_amount = data.dig(:fundamental, :divAmount)
        @div_freq = data.dig(:fundamental, :divFreq)
        @div_pay_amount = data.dig(:fundamental, :divPayAmount)
        @div_yield = data.dig(:fundamental, :divYield)
        @eps = data.dig(:fundamental, :eps)
        @fund_leverage_factor = data.dig(:fundamental, :fundLeverageFactor)
        @pe_ratio = data.dig(:fundamental, :peRatio)
        @quote_52_week_high = data.dig(:quote, :"52WeekHigh")
        @quote_52_week_low = data.dig(:quote, :"52WeekLow")
        @close_price = data.dig(:quote, :closePrice)
        @high_price = data.dig(:quote, :highPrice)
        @last_price = data.dig(:quote, :lastPrice)
        @low_price = data.dig(:quote, :lowPrice)
        @net_change = data.dig(:quote, :netChange)
        @net_percent_change = data.dig(:quote, :netPercentChange)
        @open_price = data.dig(:quote, :openPrice)
        @security_status = data.dig(:quote, :securityStatus)
        @total_volume = data.dig(:quote, :totalVolume)
        @trade_time = data.dig(:quote, :tradeTime)
        @description = data.dig(:reference, :description)
        @exchange = data.dig(:reference, :exchange)
        @exchange_name = data.dig(:reference, :exchangeName)
      end

      def mark
        (@high_price + @low_price) / 2.0
      end
    end

    class EquityQuote
      attr_reader :symbol, :asset_main_type, :asset_sub_type, :quote_type, :realtime, :ssid, :extended_ask_price,
                  :extended_ask_size, :extended_bid_price, :extended_bid_size, :extended_last_price, :extended_last_size, :extended_mark, :extended_quote_time, :extended_total_volume, :extended_trade_time, :avg_10_days_volume, :avg_1_year_volume, :declaration_date, :div_amount, :div_ex_date, :div_freq, :div_pay_amount, :div_pay_date, :div_yield, :eps, :fund_leverage_factor, :last_earnings_date, :next_div_ex_date, :next_div_pay_date, :pe_ratio, :quote_52_week_high, :quote_52_week_low, :ask_mic_id, :ask_price, :ask_size, :ask_time, :bid_mic_id, :bid_price, :bid_size, :bid_time, :close_price, :high_price, :last_mic_id, :last_price, :last_size, :low_price, :mark, :mark_change, :mark_percent_change, :net_change, :net_percent_change, :open_price, :post_market_change, :post_market_percent_change, :time, :security_status, :total_volume, :trade_time, :cusip, :description, :exchange, :exchange_name, :is_hard_to_borrow, :is_shortable, :htb_rate, :market_last_price, :market_last_size, :market_net_change, :market_percent_change, :market_trade_time

      def initialize(data)
        @symbol = data[:symbol]
        @asset_main_type = data[:assetMainType]
        @asset_sub_type = data[:assetSubType]
        @quote_type = data[:quoteType]
        @realtime = data[:realtime]
        @ssid = data[:ssid]
        @extended_ask_price = data.dig(:extended, :askPrice)
        @extended_ask_size = data.dig(:extended, :askSize)
        @extended_bid_price = data.dig(:extended, :bidPrice)
        @extended_bid_size = data.dig(:extended, :bidSize)
        @extended_last_price = data.dig(:extended, :lastPrice)
        @extended_last_size = data.dig(:extended, :lastSize)
        @extended_mark = data.dig(:extended, :mark)
        @extended_quote_time = data.dig(:extended, :quoteTime)
        @extended_total_volume = data.dig(:extended, :totalVolume)
        @extended_trade_time = data.dig(:extended, :tradeTime)
        @avg_10_days_volume = data.dig(:fundamental, :avg10DaysVolume)
        @avg_1_year_volume = data.dig(:fundamental, :avg1YearVolume)
        @declaration_date = data.dig(:fundamental, :declarationDate)
        @div_amount = data.dig(:fundamental, :divAmount)
        @div_ex_date = data.dig(:fundamental, :divExDate)
        @div_freq = data.dig(:fundamental, :divFreq)
        @div_pay_amount = data.dig(:fundamental, :divPayAmount)
        @div_pay_date = data.dig(:fundamental, :divPayDate)
        @div_yield = data.dig(:fundamental, :divYield)
        @eps = data.dig(:fundamental, :eps)
        @fund_leverage_factor = data.dig(:fundamental, :fundLeverageFactor)
        @last_earnings_date = data.dig(:fundamental, :lastEarningsDate)
        @next_div_ex_date = data.dig(:fundamental, :nextDivExDate)
        @next_div_pay_date = data.dig(:fundamental, :nextDivPayDate)
        @pe_ratio = data.dig(:fundamental, :peRatio)
        @quote_52_week_high = data.dig(:quote, :"52WeekHigh")
        @quote_52_week_low = data.dig(:quote, :"52WeekLow")
        @ask_mic_id = data.dig(:quote, :askMICId)
        @ask_price = data.dig(:quote, :askPrice)
        @ask_size = data.dig(:quote, :askSize)
        @ask_time = data.dig(:quote, :askTime)
        @bid_mic_id = data.dig(:quote, :bidMICId)
        @bid_price = data.dig(:quote, :bidPrice)
        @bid_size = data.dig(:quote, :bidSize)
        @bid_time = data.dig(:quote, :bidTime)
        @close_price = data.dig(:quote, :closePrice)
        @high_price = data.dig(:quote, :highPrice)
        @last_mic_id = data.dig(:quote, :lastMICId)
        @last_price = data.dig(:quote, :lastPrice)
        @last_size = data.dig(:quote, :lastSize)
        @low_price = data.dig(:quote, :lowPrice)
        @mark = data.dig(:quote, :mark)
        @mark_change = data.dig(:quote, :markChange)
        @mark_percent_change = data.dig(:quote, :markPercentChange)
        @net_change = data.dig(:quote, :netChange)
        @net_percent_change = data.dig(:quote, :netPercentChange)
        @open_price = data.dig(:quote, :openPrice)
        @post_market_change = data.dig(:quote, :postMarketChange)
        @post_market_percent_change = data.dig(:quote, :postMarketPercentChange)
        @quote_time = data.dig(:quote, :quoteTime)
        @security_status = data.dig(:quote, :securityStatus)
        @total_volume = data.dig(:quote, :totalVolume)
        @trade_time = data.dig(:quote, :tradeTime)
        @cusip = data.dig(:reference, :cusip)
        @description = data.dig(:reference, :description)
        @exchange = data.dig(:reference, :exchange)
        @exchange_name = data.dig(:reference, :exchangeName)
        @is_hard_to_borrow = data.dig(:reference, :isHardToBorrow)
        @is_shortable = data.dig(:reference, :isShortable)
        @htb_rate = data.dig(:reference, :htbRate)
        @market_last_price = data.dig(:regular, :regularMarketLastPrice)
        @market_last_size = data.dig(:regular, :regularMarketLastSize)
        @market_net_change = data.dig(:regular, :regularMarketNetChange)
        @market_percent_change = data.dig(:regular, :regularMarketPercentChange)
        @market_trade_time = data.dig(:regular, :regularMarketTradeTime)
      end

      def to_h
        {
          symbol: @symbol,
          asset_main_type: @asset_main_type,
          asset_sub_type: @asset_sub_type,
          quote_type: @quote_type,
          realtime: @realtime,
          ssid: @ssid,
          extended_ask_price: @extended_ask_price,
          extended_ask_size: @extended_ask_size,
          extended_bid_price: @extended_bid_price,
          extended_bid_size: @extended_bid_size,
          extended_last_price: @extended_last_price,
          extended_last_size: @extended_last_size,
          extended_mark: @extended_mark,
          extended_quote_time: @extended_quote_time,
          extended_total_volume: @extended_total_volume,
          extended_trade_time: @extended_trade_time,
          avg_10_days_volume: @avg_10_days_volume,
          avg_1_year_volume: @avg_1_year_volume,
          declaration_date: @declaration_date,
          div_amount: @div_amount,
          div_ex_date: @div_ex_date,
          div_freq: @div_freq,
          div_pay_amount: @div_pay_amount,
          div_pay_date: @div_pay_date,
          div_yield: @div_yield,
          eps: @eps,
          fund_leverage_factor: @fund_leverage_factor,
          last_earnings_date: @last_earnings_date,
          next_div_ex_date: @next_div_ex_date,
          next_div_pay_date: @next_div_pay_date,
          pe_ratio: @pe_ratio,
          quote_52_week_high: @quote_52_week_high,
          quote_52_week_low: @quote_52_week_low,
          ask_mic_id: @ask_mic_id,
          ask_price: @ask_price,
          ask_size: @ask_size,
          ask_time: @ask_time,
          bid_mic_id: @bid_mic_id,
          bid_price: @bid_price,
          bid_size: @bid_size,
          bid_time: @bid_time,
          close_price: @close_price,
          high_price: @high_price,
          last_mic_id: @last_mic_id,
          last_price: @last_price,
          last_size: @last_size,
          low_price: @low_price
        }
      end

      def to_s
        "<EquityQuote symbol: #{@symbol}, last_price: #{@last_price}, mark: #{@mark}, market_last_price: #{@market_last_price}, extended_bid_price: #{@extended_bid_price}>"
      end
    end
  end
end
