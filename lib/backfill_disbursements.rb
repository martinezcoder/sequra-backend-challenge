# frozen_string_literal: true

# Replays normal disbursement processing across the imported order history.
class BackfillDisbursements
  def self.call
    first_order_date = MerchantOrder.minimum(:ordered_on)
    return unless first_order_date

    last_order_date = MerchantOrder.maximum(:ordered_on)
    # A final WEEKLY order may wait up to six days for its merchant's weekday.
    processing_dates = first_order_date..(last_order_date + 6)

    processing_dates.each { |date| ProcessDisbursements.call(date) }
  end
end
