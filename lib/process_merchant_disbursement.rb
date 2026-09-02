# frozen_string_literal: true

# Processes one selected merchant's disbursement as an independent unit of work.
class ProcessMerchantDisbursement
  def self.call(merchant, date, commission_calculator: CommissionCalculator)
    new(merchant, date, commission_calculator:).call
  end

  def initialize(merchant, date, commission_calculator:)
    @merchant = merchant
    @date = date
    @commission_calculator = commission_calculator
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
    MerchantOrder.where(merchant: @merchant, ordered_on: eligible_dates)
  end

  def eligible_dates
    case @merchant.disbursement_frequency
    when "DAILY"
      @date
    when "WEEKLY"
      # The challenge does not define the weekly order window. This implementation
      # uses the seven calendar dates ending on the processing date, inclusive.
      (@date - 6)..@date
    else
      raise ArgumentError, "Unsupported disbursement frequency: #{@merchant.disbursement_frequency.inspect}"
    end
  end

  def find_or_create_disbursement
    @merchant.disbursements.find_or_create_by!(disbursed_on: @date) do |disbursement|
      disbursement.reference = disbursement_reference
    end
  end

  def disbursement_reference
    "D#{@date.strftime('%Y%m%d')}M#{@merchant.reference}"
  end

  def process_order(order, disbursement)
    order.update!(disbursement:, fee_cents: @commission_calculator.call(order.amount_cents))
  end
end
