# frozen_string_literal: true

module Reports
  # Aggregates persisted disbursement and monthly fee data by calendar year.
  class Annual
    DISBURSEMENT_YEAR = Arel.sql("EXTRACT(YEAR FROM disbursements.disbursed_on)")
    MONTHLY_FEE_YEAR = Arel.sql("EXTRACT(YEAR FROM monthly_fees.period)")
    HEADERS = [
      "Year",
      "Number of disbursements",
      "Amount disbursed to merchants",
      "Amount of order fees",
      "Number of monthly fees charged",
      "Amount of monthly fees charged"
    ].freeze

    def self.call
      new.call
    end

    def self.to_markdown(rows = call)
      lines = [
        "| #{HEADERS.join(' | ')} |",
        "| #{HEADERS.map { '---' }.join(' | ')} |"
      ]

      rows.each do |row|
        lines << "| #{present(row).join(' | ')} |"
      end

      lines.join("\n")
    end

    def call
      aggregates = annual_aggregates

      aggregates.keys.sort.map { |year| build_row(year, aggregates.fetch(year)) }
    end

    def self.present(row)
      [
        row.fetch(:year),
        row.fetch(:number_of_disbursements),
        Money.from_cents(row.fetch(:amount_disbursed_cents)),
        Money.from_cents(row.fetch(:order_fees_cents)),
        row.fetch(:number_of_monthly_fees_charged),
        Money.from_cents(row.fetch(:monthly_fees_cents))
      ]
    end
    private_class_method :present

    private

    def build_row(year, values)
      order_fees_cents = values.fetch(:order_fees_cents, 0)

      {
        year:, number_of_disbursements: values.fetch(:number_of_disbursements, 0),
        amount_disbursed_cents: values.fetch(:gross_cents, 0) - order_fees_cents,
        order_fees_cents:,
        number_of_monthly_fees_charged: values.fetch(:number_of_monthly_fees_charged, 0),
        monthly_fees_cents: values.fetch(:monthly_fees_cents, 0)
      }
    end

    def annual_aggregates
      Hash.new { |years, year| years[year] = {} }.tap do |years|
        merge(years, disbursement_counts, :number_of_disbursements)
        merge(years, order_amounts, :gross_cents)
        merge(years, order_fees, :order_fees_cents)
        merge(years, monthly_fee_counts, :number_of_monthly_fees_charged)
        merge(years, monthly_fee_amounts, :monthly_fees_cents)
      end
    end

    def disbursement_counts
      normalize_years(Disbursement.group(DISBURSEMENT_YEAR).count)
    end

    def order_amounts
      normalize_years(disbursed_orders.group(DISBURSEMENT_YEAR).sum(:amount_cents))
    end

    def order_fees
      normalize_years(disbursed_orders.group(DISBURSEMENT_YEAR).sum(:fee_cents))
    end

    def monthly_fee_counts
      normalize_years(MonthlyFee.where("amount_cents > 0").group(MONTHLY_FEE_YEAR).count)
    end

    def monthly_fee_amounts
      normalize_years(MonthlyFee.group(MONTHLY_FEE_YEAR).sum(:amount_cents))
    end

    def disbursed_orders
      MerchantOrder.joins(:disbursement)
    end

    def normalize_years(values)
      values.to_h { |year, value| [year.to_i, value] }
    end

    def merge(years, values, key)
      values.each { |year, value| years[year][key] = value }
    end
  end
end
