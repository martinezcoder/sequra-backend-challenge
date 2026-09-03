# frozen_string_literal: true

# Disbursement processing domain.
module Disbursements
  # Delegates date-based processing for merchants on the DAILY schedule.
  class ProcessDaily
    def self.call(date)
      Merchant.where(disbursement_frequency: "DAILY").find_each do |merchant|
        ProcessMerchant.call(merchant, date)
      end
    end
  end
end
