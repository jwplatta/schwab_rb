# frozen_string_literal: true

require "spec_helper"

describe SchwabRb::Order do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
  describe "constants" do
    it "returns correct statuses" do
      statuses = SchwabRb::Order::Statuses.constants.map { |const| SchwabRb::Order::Statuses.const_get(const) }
      expect(statuses).to match_array(%w[
                                        AWAITING_PARENT_ORDER
                                        AWAITING_CONDITION
                                        AWAITING_STOP_CONDITION
                                        AWAITING_MANUAL_REVIEW
                                        ACCEPTED
                                        AWAITING_UR_OUT
                                        PENDING_ACTIVATION
                                        QUEUED
                                        WORKING
                                        REJECTED
                                        PENDING_CANCEL
                                        CANCELED
                                        PENDING_REPLACE
                                        REPLACED
                                        FILLED
                                        EXPIRED
                                        NEW
                                        AWAITING_RELEASE_TIME
                                        PENDING_ACKNOWLEDGEMENT
                                        PENDING_RECALL
                                        UNKNOWN
                                      ])
    end
    it "returns correct types" do
      types = SchwabRb::Order::Types.constants.map { |const| SchwabRb::Order::Types.const_get(const) }
      expect(types).to match_array(%w[
                                     TRAILING_STOP_LIMIT
                                     NET_DEBIT
                                     NET_CREDIT
                                     NET_ZERO
                                     LIMIT_ON_CLOSE
                                     MARKET
                                     LIMIT
                                     STOP
                                     STOP_LIMIT
                                     TRAILING_STOP
                                     CABINET
                                     NON_MARKETABLE
                                     MARKET_ON_CLOSE
                                     EXERCISE
                                   ])
    end
  end
end
