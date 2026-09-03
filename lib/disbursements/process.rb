# frozen_string_literal: true

# Disbursement processing domain.
module Disbursements
  # Coordinates every supported disbursement schedule for a business date.
  class Process
    # Keep both flows independent so the execution strategy can evolve without
    # changing their core processing logic.
    def self.call(date)
      ProcessDaily.call(date)
      ProcessWeekly.call(date)
    end
  end
end
