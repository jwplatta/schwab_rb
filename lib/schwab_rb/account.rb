module SchwabRb
  class Account
    module Status
      POSITIONS = 'positions'
    end

    def self.statuses
      Status.constants.map { |const| Status.const_get(const) }
    end
  end
end
