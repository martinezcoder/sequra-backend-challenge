# frozen_string_literal: true

require "spec_helper"

RSpec.describe Reports::Annual do
  describe ".call" do
    let(:merchant) { create(:merchant) }

    before do
      create_disbursed_order(year: 2025, amount_cents: 1_000, fee_cents: 100, ordered_on: Date.new(2024, 12, 31))
      create(:monthly_fee, merchant:, period: Date.new(2025, 1, 1), amount_cents: 50)
      create(:monthly_fee, merchant:, period: Date.new(2025, 2, 1), amount_cents: 0)

      create_disbursed_order(year: 2026, amount_cents: 2_000, fee_cents: 250)
      create(:monthly_fee, merchant:, period: Date.new(2026, 1, 1), amount_cents: 200)
    end

    it "counts disbursements in the year they were completed" do
      expect(row_for(2025).fetch(:number_of_disbursements)).to eq(1)
    end

    it "reports merchant amounts net of order fees without subtracting monthly fees" do
      expect(row_for(2025).fetch(:amount_disbursed_cents)).to eq(900)
    end

    it "uses persisted order fees without recalculating commissions", :aggregate_failures do
      allow(Commissions::Calculator).to receive(:call)

      expect(row_for(2025).fetch(:order_fees_cents)).to eq(100)
      expect(Commissions::Calculator).not_to have_received(:call)
    end

    it "attributes monthly fees by their period" do
      expect(row_for(2025).fetch(:monthly_fees_cents)).to eq(50)
    end

    it "does not count zero-value evaluations as monthly fees charged" do
      expect(row_for(2025).fetch(:number_of_monthly_fees_charged)).to eq(1)
    end

    it "counts positive monthly fees and sums their amounts" do
      expect(row_for(2026)).to include(
        number_of_monthly_fees_charged: 1,
        monthly_fees_cents: 200
      )
    end

    it "reports data from different years independently" do
      expect(described_class.call).to contain_exactly(
        include(year: 2025, amount_disbursed_cents: 900, order_fees_cents: 100),
        include(year: 2026, amount_disbursed_cents: 1_750, order_fees_cents: 250)
      )
    end
  end

  describe ".to_markdown" do
    subject(:output) { described_class.to_markdown(rows) }

    let(:rows) do
      [{
        year: 2025,
        number_of_disbursements: 1,
        amount_disbursed_cents: 900,
        order_fees_cents: 100,
        number_of_monthly_fees_charged: 1,
        monthly_fees_cents: 50
      }]
    end

    it "renders the required columns" do
      expect(output.lines.first).to eq(
        "| Year | Number of disbursements | Amount disbursed to merchants | Amount of order fees | " \
        "Number of monthly fees charged | Amount of monthly fees charged |\n"
      )
    end

    it "renders euro-denominated amounts" do
      expect(output).to include("| 2025 | 1 | 9.00 | 1.00 | 1 | 0.50 |")
    end
  end

  def create_disbursed_order(year:, amount_cents:, fee_cents:, ordered_on: Date.new(year, 1, 1))
    disbursement = create(:disbursement, merchant:, disbursed_on: Date.new(year, 1, 2))
    create(:merchant_order, merchant:, disbursement:, amount_cents:, fee_cents:, ordered_on:)
  end

  def row_for(year)
    described_class.call.find { |row| row.fetch(:year) == year }
  end
end
