# frozen_string_literal: true

module SchwabRb
  module Orders
    module Session
      # Normal market hours, from 9:30am to 4:00pm Eastern.
      NORMAL = "NORMAL"

      # Premarket session, from 8:00am to 9:30am Eastern.
      AM = "AM"

      # After-market session, from 4:00pm to 8:00pm Eastern.
      PM = "PM"

      # Orders are active during all trading sessions except the overnight
      # session. This is the union of ``NORMAL``, ``AM``, and ``PM``.
      SEAMLESS = "SEAMLESS"
    end
  end
end
