# frozen_string_literal: true

# Delegates processing for WEEKLY merchants scheduled on the requested weekday.
class ProcessWeeklyDisbursements
  def self.call(date)
    Merchant.where(disbursement_frequency: "WEEKLY").find_each do |merchant|
      # Keep the weekday rule explicit in Ruby while the merchant dataset is small.
      # Database-side filtering can be introduced if merchant volume justifies it.
      next unless merchant.live_on&.wday == date.wday

      ProcessWeeklyMerchantDisbursement.call(merchant, date)
    end
  end
end
