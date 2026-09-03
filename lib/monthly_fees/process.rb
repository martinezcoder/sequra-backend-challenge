# frozen_string_literal: true

# Monthly minimum fee domain.
module MonthlyFees
  # Evaluates and persists every merchant's minimum fee for one calendar month.
  class Process
    def self.call(period)
      new(period).call
    end

    def initialize(period)
      unless period.is_a?(Date) && period.day == 1
        raise ArgumentError, "period must be a Date representing the first day of a month"
      end

      @period = period
    end

    def call
      Merchant.find_each { |merchant| process_merchant(merchant) }
    end

    private

    def process_merchant(merchant)
      amount_cents = [merchant.minimum_monthly_fee_cents - commissions_cents(merchant), 0].max

      merchant.monthly_fees.find_or_initialize_by(period: @period).update!(amount_cents:)
    end

    def commissions_cents(merchant)
      merchant.merchant_orders
              .joins(:disbursement)
              .where(disbursements: { disbursed_on: @period...@period.next_month })
              .sum(:fee_cents)
    end
  end
end
