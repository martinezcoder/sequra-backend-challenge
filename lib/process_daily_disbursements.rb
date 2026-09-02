# frozen_string_literal: true

# Delegates date-based processing for merchants on the DAILY schedule.
class ProcessDailyDisbursements
  def self.call(date)
    Merchant.where(disbursement_frequency: "DAILY").find_each do |merchant|
      ProcessMerchantDisbursement.call(merchant, date)
    end
  end
end
