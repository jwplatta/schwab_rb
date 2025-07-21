# frozen_string_literal: true

module SchwabRb
  module DataObjects
    class MarketHours
      attr_reader :markets

      class << self
        def build(data)
          new(data)
        end
      end

      def initialize(data)
        @markets = {}
        data.each do |market_type, market_data|
          @markets[market_type] = {}
          market_data.each do |product_key, product_data|
            @markets[market_type][product_key] = MarketInfo.new(product_data)
          end
        end
      end

      def to_h
        result = {}
        @markets.each do |market_type, market_data|
          result[market_type] = {}
          market_data.each do |product_key, market_info|
            result[market_type][product_key] = market_info.to_h
          end
        end
        result
      end

      def equity
        @markets["equity"] || {}
      end

      def option
        @markets["option"] || {}
      end

      def future
        @markets["future"] || {}
      end

      def forex
        @markets["forex"] || {}
      end

      def bond
        @markets["bond"] || {}
      end

      def market_types
        @markets.keys
      end

      def find_by_market_type(market_type)
        @markets[market_type.to_s]
      end

      def find_market_info(market_type, product_key)
        market_data = find_by_market_type(market_type)
        return nil unless market_data

        market_data[product_key.to_s]
      end

      def open_markets
        result = {}
        @markets.each do |market_type, market_data|
          market_data.each do |product_key, market_info|
            if market_info.open?
              result[market_type] ||= {}
              result[market_type][product_key] = market_info
            end
          end
        end
        result
      end

      def closed_markets
        result = {}
        @markets.each do |market_type, market_data|
          market_data.each do |product_key, market_info|
            unless market_info.open?
              result[market_type] ||= {}
              result[market_type][product_key] = market_info
            end
          end
        end
        result
      end

      def any_open?
        @markets.any? do |_, market_data|
          market_data.any? { |_, market_info| market_info.open? }
        end
      end

      def all_closed?
        !any_open?
      end

      def each_market
        return enum_for(:each_market) unless block_given?

        @markets.each do |market_type, market_data|
          market_data.each do |product_key, market_info|
            yield(market_type, product_key, market_info)
          end
        end
      end

      include Enumerable

      def each(&block)
        each_market(&block)
      end

      class MarketInfo
        attr_reader :date, :market_type, :product, :product_name, :is_open, :session_hours

        def initialize(data)
          @date = data["date"]
          @market_type = data["marketType"]
          @product = data["product"]
          @product_name = data["productName"]
          @is_open = data["isOpen"]
          @session_hours = data["sessionHours"] ? SessionHours.new(data["sessionHours"]) : nil
        end

        def to_h
          result = {
            "date" => @date,
            "marketType" => @market_type,
            "product" => @product,
            "isOpen" => @is_open
          }
          result["productName"] = @product_name if @product_name
          result["sessionHours"] = @session_hours.to_h if @session_hours
          result
        end

        def open?
          @is_open == true
        end

        def closed?
          !open?
        end

        def date_object
          Date.parse(@date) if @date
        end

        def has_session_hours?
          !@session_hours.nil?
        end

        def regular_market_hours
          return nil unless @session_hours

          @session_hours.regular_market
        end

        def pre_market_hours
          return nil unless @session_hours

          @session_hours.pre_market
        end

        def post_market_hours
          return nil unless @session_hours

          @session_hours.post_market
        end

        def equity?
          @market_type == "EQUITY"
        end

        def option?
          @market_type == "OPTION"
        end

        def future?
          @market_type == "FUTURE"
        end

        def forex?
          @market_type == "FOREX"
        end

        def bond?
          @market_type == "BOND"
        end
      end

      class SessionHours
        attr_reader :regular_market, :pre_market, :post_market

        def initialize(data)
          @regular_market = parse_session_periods(data["regularMarket"])
          @pre_market = parse_session_periods(data["preMarket"])
          @post_market = parse_session_periods(data["postMarket"])
        end

        def to_h
          result = {}
          result["regularMarket"] = @regular_market.map(&:to_h) if @regular_market
          result["preMarket"] = @pre_market.map(&:to_h) if @pre_market
          result["postMarket"] = @post_market.map(&:to_h) if @post_market
          result
        end

        def has_regular_market?
          @regular_market && !@regular_market.empty?
        end

        def has_pre_market?
          @pre_market && !@pre_market.empty?
        end

        def has_post_market?
          @post_market && !@post_market.empty?
        end

        private

        def parse_session_periods(periods_data)
          return nil unless periods_data && periods_data.is_a?(Array)

          periods_data.map { |period_data| SessionPeriod.new(period_data) }
        end
      end

      class SessionPeriod
        attr_reader :start_time, :end_time

        def initialize(data)
          @start_time = data["start"]
          @end_time = data["end"]
        end

        def to_h
          {
            "start" => @start_time,
            "end" => @end_time
          }
        end

        def start_time_object
          Time.parse(@start_time) if @start_time
        end

        def end_time_object
          Time.parse(@end_time) if @end_time
        end

        def duration_minutes
          return nil unless @start_time && @end_time

          start_obj = start_time_object
          end_obj = end_time_object
          return nil unless start_obj && end_obj

          ((end_obj - start_obj) / 60).to_i
        end

        def active_now?
          return false unless @start_time && @end_time

          now = Time.now
          start_obj = start_time_object
          end_obj = end_time_object
          return false unless start_obj && end_obj

          now >= start_obj && now <= end_obj
        end
      end
    end
  end
end
