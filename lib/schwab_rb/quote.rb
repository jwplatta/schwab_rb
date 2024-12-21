module SchwabRb
  class Quote
    module Type
      QUOTE = 'quote'
      FUNDAMENTAL = 'fundamental'
      EXTENDED = 'extended'
      REFERENCE = 'reference'
      REGULAR = 'regular'
    end

    def self.types
      Type.constants.map { |const| Type.const_get(const) }
    end
  end
end
