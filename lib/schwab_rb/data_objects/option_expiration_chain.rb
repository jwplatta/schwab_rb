# frozen_string_literal: true

module SchwabRb
  module DataObjects
    class OptionExpirationChain
      attr_reader :expiration_list, :status

      class << self
        def build(data)
          new(data)
        end
      end

      def initialize(data)
        @expiration_list = Array(fetch_value(data, "expirationList")).map { |expiration_data| Expiration.new(expiration_data) }
        @status = fetch_value(data, "status")
      end

      def to_h
        {
          "expirationList" => @expiration_list.map(&:to_h),
          "status" => @status
        }
      end

      def find_by_date(date)
        date_str = date.is_a?(Date) ? date.strftime("%Y-%m-%d") : date.to_s
        @expiration_list.find { |exp| exp.expiration_date == date_str }
      end

      def find_by_days_to_expiration(days)
        @expiration_list.select { |exp| exp.days_to_expiration == days }
      end

      def weekly_expirations
        @expiration_list.select { |exp| exp.expiration_type == "W" }
      end

      def monthly_expirations
        @expiration_list.select { |exp| exp.expiration_type == "M" }
      end

      def quarterly_expirations
        @expiration_list.select { |exp| exp.expiration_type == "Q" }
      end

      def standard_expirations
        @expiration_list.select(&:standard?)
      end

      def non_standard_expirations
        @expiration_list.reject(&:standard?)
      end

      def count
        @expiration_list.length
      end
      alias size count
      alias length count

      def empty?
        @expiration_list.empty?
      end

      def each(&block)
        return enum_for(:each) unless block_given?

        @expiration_list.each(&block)
      end

      include Enumerable

      private

      def fetch_value(data, key)
        data[key] || data[key.to_sym]
      end

      public

      class Expiration
        attr_reader :expiration_date, :days_to_expiration, :expiration_type,
                    :settlement_type, :option_roots, :standard

        def initialize(data)
          @expiration_date = fetch_value(data, "expirationDate")
          @days_to_expiration = fetch_value(data, "daysToExpiration")
          @expiration_type = fetch_value(data, "expirationType")
          @settlement_type = fetch_value(data, "settlementType")
          @option_roots = fetch_value(data, "optionRoots")
          @standard = fetch_value(data, "standard")
        end

        def to_h
          {
            "expirationDate" => @expiration_date,
            "daysToExpiration" => @days_to_expiration,
            "expirationType" => @expiration_type,
            "settlementType" => @settlement_type,
            "optionRoots" => @option_roots,
            "standard" => @standard
          }
        end

        def standard?
          @standard == true
        end

        def weekly?
          @expiration_type == "W"
        end

        def monthly?
          @expiration_type == "M"
        end

        def quarterly?
          @expiration_type == "Q"
        end

        def special?
          @expiration_type == "S"
        end

        def date_object
          Date.parse(@expiration_date) if @expiration_date
        end

        def expires_in_days?(days)
          @days_to_expiration == days
        end

        def expires_today?
          @days_to_expiration.zero?
        end

        def expires_tomorrow?
          @days_to_expiration == 1
        end

        private

        def fetch_value(data, key)
          data[key] || data[key.to_sym]
        end
      end
    end
  end
end
