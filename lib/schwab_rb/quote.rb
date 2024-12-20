module SchwabRb
  class Quote
    module Type
      QUOTE = 'quote'
      FUNDAMENTAL = 'fundamental'
      EXTENDED = 'extended'
      REFERENCE = 'reference'
      REGULAR = 'regular'

      def self.fields
        constants.map { |const| const_get(const) }
      end
    end
  end
end