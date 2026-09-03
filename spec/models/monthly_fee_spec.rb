# frozen_string_literal: true

require "spec_helper"

RSpec.describe MonthlyFee do
  subject(:monthly_fee) { create(:monthly_fee) }

  it "belongs to its merchant" do
    expect(monthly_fee.merchant.monthly_fees).to include(monthly_fee)
  end

  it "normalizes its period to the first day of the month" do
    monthly_fee = create(:monthly_fee, period: Date.new(2026, 1, 20))

    expect(monthly_fee.reload.period).to eq(Date.new(2026, 1, 1))
  end

  it "persists a zero amount" do
    monthly_fee = create(:monthly_fee, amount_cents: 0)

    expect(monthly_fee.reload.amount_cents).to be_zero
  end

  context "when the merchant already has a fee for the same month" do
    it "rejects the duplicate at the database level" do
      expect do
        create(:monthly_fee, merchant: monthly_fee.merchant, period: Date.new(2026, 1, 31))
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
