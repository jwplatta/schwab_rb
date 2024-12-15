module SchwabRb
  class Option
    module ContractType
      CALL = 'CALL'
      PUT = 'PUT'
      ALL = 'ALL'
    end

    module Strategy
      SINGLE = 'SINGLE'
      ANALYTICAL = 'ANALYTICAL'
      COVERED = 'COVERED'
      VERTICAL = 'VERTICAL'
      CALENDAR = 'CALENDAR'
      STRANGLE = 'STRANGLE'
      STRADDLE = 'STRADDLE'
      BUTTERFLY = 'BUTTERFLY'
      CONDOR = 'CONDOR'
      DIAGONAL = 'DIAGONAL'
      COLLAR = 'COLLAR'
      ROLL = 'ROLL'
    end

    module StrikeRange
      IN_THE_MONEY = 'ITM'
      NEAR_THE_MONEY = 'NTM'
      OUT_OF_THE_MONEY = 'OTM'
      STRIKES_ABOVE_MARKET = 'SAK'
      STRIKES_BELOW_MARKET = 'SBK'
      STRIKES_NEAR_MARKET = 'SNK'
      ALL = 'ALL'
    end

    module Type
      STANDARD = 'S'
      NON_STANDARD = 'NS'
      ALL = 'ALL'
    end

    module ExpirationMonth
      JANUARY = 'JAN'
      FEBRUARY = 'FEB'
      MARCH = 'MAR'
      APRIL = 'APR'
      MAY = 'MAY'
      JUNE = 'JUN'
      JULY = 'JUL'
      AUGUST = 'AUG'
      SEPTEMBER = 'SEP'
      OCTOBER = 'OCT'
      NOVEMBER = 'NOV'
      DECEMBER = 'DEC'
      ALL = 'ALL'
    end

    module Entitlement
      PAYING_PRO = 'PP'
      NON_PRO = 'NP'
      NON_PAYING_PRO = 'PN'
    end
  end
end
