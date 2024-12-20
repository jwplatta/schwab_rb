module SchwabRb
  class PriceHistory
    module PeriodType
      DAY = 'day'
      MONTH = 'month'
      YEAR = 'year'
      YEAR_TO_DATE = 'ytd'
    end

    module Period
      ONE_DAY = 1
      TWO_DAYS = 2
      THREE_DAYS = 3
      FOUR_DAYS = 4
      FIVE_DAYS = 5
      TEN_DAYS = 10

      ONE_MONTH = 1
      TWO_MONTHS = 2
      THREE_MONTHS = 3
      SIX_MONTHS = 6

      ONE_YEAR = 1
      TWO_YEARS = 2
      THREE_YEARS = 3
      FIVE_YEARS = 5
      TEN_YEARS = 10
      FIFTEEN_YEARS = 15
      TWENTY_YEARS = 20

      YEAR_TO_DATE = 1
    end

    module FrequencyType
      MINUTE = 'minute'
      DAILY = 'daily'
      WEEKLY = 'weekly'
      MONTHLY = 'monthly'
    end

    module Frequency
      EVERY_MINUTE = 1
      EVERY_FIVE_MINUTES = 5
      EVERY_TEN_MINUTES = 10
      EVERY_FIFTEEN_MINUTES = 15
      EVERY_THIRTY_MINUTES = 30

      DAILY = 1
      WEEKLY = 1
      MONTHLY = 1
    end

    def self.periods
      Period.constants.map { |const| Period.const_get(const) }
    end

    def self.period_types
      PeriodType.constants.map { |const| PeriodType.const_get(const) }
    end

    def self.frequencies
      Frequency.constants.map { |const| Frequency.const_get(const) }
    end

    def self.frequency_types
      FrequencyType.constants.map { |const| FrequencyType.const_get(const) }
  end
end
