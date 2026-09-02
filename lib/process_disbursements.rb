# frozen_string_literal: true

# Coordinates every supported disbursement schedule for a business date.
class ProcessDisbursements
  # Keep both flows independent so the execution strategy can evolve without
  # changing their core processing logic.
  def self.call(date)
    ProcessDailyDisbursements.call(date)
    ProcessWeeklyDisbursements.call(date)
  end
end
