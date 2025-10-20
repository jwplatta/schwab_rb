# frozen_string_literal: true

module SchwabRb
  class Order
    module Statuses
      AWAITING_PARENT_ORDER = "AWAITING_PARENT_ORDER"
      AWAITING_CONDITION = "AWAITING_CONDITION"
      AWAITING_STOP_CONDITION = "AWAITING_STOP_CONDITION"
      AWAITING_MANUAL_REVIEW = "AWAITING_MANUAL_REVIEW"
      ACCEPTED = "ACCEPTED"
      AWAITING_UR_OUT = "AWAITING_UR_OUT"
      PENDING_ACTIVATION = "PENDING_ACTIVATION"
      QUEUED = "QUEUED"
      WORKING = "WORKING"
      REJECTED = "REJECTED"
      PENDING_CANCEL = "PENDING_CANCEL"
      CANCELED = "CANCELED"
      PENDING_REPLACE = "PENDING_REPLACE"
      REPLACED = "REPLACED"
      FILLED = "FILLED"
      EXPIRED = "EXPIRED"
      NEW = "NEW"
      AWAITING_RELEASE_TIME = "AWAITING_RELEASE_TIME"
      PENDING_ACKNOWLEDGEMENT = "PENDING_ACKNOWLEDGEMENT"
      PENDING_RECALL = "PENDING_RECALL"
      UNKNOWN = "UNKNOWN"
    end

    module Types
      MARKET = "MARKET"
      LIMIT = "LIMIT"
      STOP = "STOP"
      STOP_LIMIT = "STOP_LIMIT"
      TRAILING_STOP = "TRAILING_STOP"
      CABINET = "CABINET"
      NON_MARKETABLE = "NON_MARKETABLE"
      MARKET_ON_CLOSE = "MARKET_ON_CLOSE"
      EXERCISE = "EXERCISE"
      TRAILING_STOP_LIMIT = "TRAILING_STOP_LIMIT"
      NET_DEBIT = "NET_DEBIT"
      NET_CREDIT = "NET_CREDIT"
      NET_ZERO = "NET_ZERO"
      LIMIT_ON_CLOSE = "LIMIT_ON_CLOSE"
    end

    module OrderStrategyTypes
      SINGLE = "SINGLE"
      CANCEL = "CANCEL"
      RECALL = "RECALL"
      PAIR = "PAIR"
      FLATTEN = "FLATTEN"
      TWO_DAY_SWAP = "TWO_DAY_SWAP"
      BLAST_ALL = "BLAST_ALL"
      OCO = "OCO"
      TRIGGER = "TRIGGER"
    end

    module ComplexOrderStrategyTypes
      # Explicit order strategies for executing multi-leg options orders.

      # No complex order strategy. This is the default.
      NONE = "NONE"
      COVERED = "COVERED"
      VERTICAL = "VERTICAL"
      BACK_RATIO = "BACK_RATIO"
      CALENDAR = "CALENDAR"
      DIAGONAL = "DIAGONAL"
      STRADDLE = "STRADDLE"
      STRANGLE = "STRANGLE"
      COLLAR_SYNTHETIC = "COLLAR_SYNTHETIC"
      BUTTERFLY = "BUTTERFLY"
      CONDOR = "CONDOR"
      IRON_CONDOR = "IRON_CONDOR"
      VERTICAL_ROLL = "VERTICAL_ROLL"
      COLLAR_WITH_STOCK = "COLLAR_WITH_STOCK"
      DOUBLE_DIAGONAL = "DOUBLE_DIAGONAL"
      UNBALANCED_BUTTERFLY = "UNBALANCED_BUTTERFLY"
      UNBALANCED_CONDOR = "UNBALANCED_CONDOR"
      UNBALANCED_IRON_CONDOR = "UNBALANCED_IRON_CONDOR"
      UNBALANCED_VERTICAL_ROLL = "UNBALANCED_VERTICAL_ROLL"

      # Mutual fund swap
      MUTUAL_FUND_SWAP = "MUTUAL_FUND_SWAP"

      # A custom multi-leg order strategy.
      CUSTOM = "CUSTOM"
    end

    ALL_ORDER_STRATEGY_TYPES = [
      OrderStrategyTypes::SINGLE,
      OrderStrategyTypes::CANCEL,
      OrderStrategyTypes::RECALL,
      OrderStrategyTypes::PAIR,
      OrderStrategyTypes::FLATTEN,
      OrderStrategyTypes::TWO_DAY_SWAP,
      OrderStrategyTypes::BLAST_ALL,
      OrderStrategyTypes::OCO,
      OrderStrategyTypes::TRIGGER,
      ComplexOrderStrategyTypes::NONE,
      ComplexOrderStrategyTypes::COVERED,
      ComplexOrderStrategyTypes::VERTICAL,
      ComplexOrderStrategyTypes::BACK_RATIO,
      ComplexOrderStrategyTypes::CALENDAR,
      ComplexOrderStrategyTypes::DIAGONAL,
      ComplexOrderStrategyTypes::STRADDLE,
      ComplexOrderStrategyTypes::STRANGLE,
      ComplexOrderStrategyTypes::COLLAR_SYNTHETIC,
      ComplexOrderStrategyTypes::BUTTERFLY,
      ComplexOrderStrategyTypes::CONDOR,
      ComplexOrderStrategyTypes::IRON_CONDOR,
      ComplexOrderStrategyTypes::VERTICAL_ROLL,
      ComplexOrderStrategyTypes::COLLAR_WITH_STOCK,
      ComplexOrderStrategyTypes::DOUBLE_DIAGONAL,
      ComplexOrderStrategyTypes::UNBALANCED_BUTTERFLY,
      ComplexOrderStrategyTypes::UNBALANCED_CONDOR,
      ComplexOrderStrategyTypes::UNBALANCED_IRON_CONDOR,
      ComplexOrderStrategyTypes::UNBALANCED_VERTICAL_ROLL,
      ComplexOrderStrategyTypes::MUTUAL_FUND_SWAP,
      ComplexOrderStrategyTypes::CUSTOM
    ].freeze
  end
end
