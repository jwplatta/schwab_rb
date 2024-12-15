module SchwabRb
  class Order
    module Status
      AWAITING_PARENT_ORDER = 'AWAITING_PARENT_ORDER'
      AWAITING_CONDITION = 'AWAITING_CONDITION'
      AWAITING_STOP_CONDITION = 'AWAITING_STOP_CONDITION'
      AWAITING_MANUAL_REVIEW = 'AWAITING_MANUAL_REVIEW'
      ACCEPTED = 'ACCEPTED'
      AWAITING_UR_OUT = 'AWAITING_UR_OUT'
      PENDING_ACTIVATION = 'PENDING_ACTIVATION'
      QUEUED = 'QUEUED'
      WORKING = 'WORKING'
      REJECTED = 'REJECTED'
      PENDING_CANCEL = 'PENDING_CANCEL'
      CANCELED = 'CANCELED'
      PENDING_REPLACE = 'PENDING_REPLACE'
      REPLACED = 'REPLACED'
      FILLED = 'FILLED'
      EXPIRED = 'EXPIRED'
      NEW = 'NEW'
      AWAITING_RELEASE_TIME = 'AWAITING_RELEASE_TIME'
      PENDING_ACKNOWLEDGEMENT = 'PENDING_ACKNOWLEDGEMENT'
      PENDING_RECALL = 'PENDING_RECALL'
      UNKNOWN = 'UNKNOWN'

      def self.all
        constants.map { |const| const_get(const) }
      end
    end
  end
end