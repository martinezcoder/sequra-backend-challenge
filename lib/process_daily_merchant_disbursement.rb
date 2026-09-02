# frozen_string_literal: true

# Processes one DAILY merchant's disbursement as an independent unit of work.
class ProcessDailyMerchantDisbursement
  def self.call(merchant, date)
    new(merchant, date).call
  end

  def initialize(merchant, date)
    @merchant = merchant
    @date = date
  end

  def call
    ActiveRecord::Base.transaction(requires_new: true) do
      orders = eligible_orders
      next unless orders.exists?

      disbursement = find_or_create_disbursement
      orders.find_each { |order| process_order(order, disbursement) }
    end
  end

  private

  def eligible_orders
    MerchantOrder.where(merchant: @merchant, created_at: @date...@date.next_day)
  end

  def find_or_create_disbursement
    @merchant.disbursements.find_or_create_by!(disbursed_on: @date) do |disbursement|
      disbursement.reference = "D#{@date.strftime('%Y%m%d')}M#{@merchant.id}"
    end
  end

  def process_order(order, disbursement)
    # One percent of an amount in cents is divided by 100; ceildiv applies the
    # required upward rounding while keeping the calculation entirely integral.
    order.update!(disbursement:, fee_cents: order.amount_cents.ceildiv(100))
  end
end
