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
        @expiration_list = data["expirationList"]&.map { |expiration_data| Expiration.new(expiration_data) } || []
        @status = data["status"]
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

      class Expiration
        attr_reader :expiration_date, :days_to_expiration, :expiration_type,
                    :settlement_type, :option_roots, :standard

        def initialize(data)
          @expiration_date = data["expirationDate"]
          @days_to_expiration = data["daysToExpiration"]
          @expiration_type = data["expirationType"]
          @settlement_type = data["settlementType"]
          @option_roots = data["optionRoots"]
          @standard = data["standard"]
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
      end
    end
  end
end
