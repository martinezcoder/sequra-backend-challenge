# frozen_string_literal: true

module MonthlyFees
  # Replays monthly minimum fee processing across completed disbursement history.
  class Backfill
    def self.call
      first_period = Disbursement.minimum(:disbursed_on)&.beginning_of_month
      return unless first_period

      final_period = Disbursement.maximum(:disbursed_on).beginning_of_month
      period = first_period

      while period <= final_period
        Process.call(period)
        period = period.next_month
      end
    end
  end
end
