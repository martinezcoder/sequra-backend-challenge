# frozen_string_literal: true

require "spec_helper"

RSpec.describe MonthlyFees::Process do
  let(:period) { Date.new(2026, 2, 1) }
  let!(:merchant) { create(:merchant, minimum_monthly_fee_cents: 500) }

  describe ".call" do
    context "when commissions are below the configured minimum" do
      before do
        create_commission(200, disbursed_on: period)
      end

      it "stores the remaining difference" do
        described_class.call(period)

        expect(monthly_fee.amount_cents).to eq(300)
      end
    end

    context "when commissions exactly reach the configured minimum" do
      before do
        create_commission(500, disbursed_on: period)
      end

      it "persists a zero-value monthly fee" do
        described_class.call(period)

        expect(monthly_fee.amount_cents).to be_zero
      end
    end

    context "when commissions exceed the configured minimum" do
      before do
        create_commission(501, disbursed_on: period)
      end

      it "stores zero" do
        described_class.call(period)

        expect(monthly_fee.amount_cents).to be_zero
      end
    end

    context "when the merchant has no commissions in the period" do
      it "stores the full configured minimum" do
        described_class.call(period)

        expect(monthly_fee.amount_cents).to eq(500)
      end
    end

    context "when disbursements exist outside the requested month" do
      before do
        create_commission(500, disbursed_on: period - 1)
        create_commission(100, disbursed_on: period)
        create_commission(500, disbursed_on: period.next_month)
      end

      it "uses only commissions from disbursements completed in the month" do
        described_class.call(period)

        expect(monthly_fee.amount_cents).to eq(400)
      end
    end

    context "when an order date and its disbursement month differ" do
      before do
        create_commission(100, disbursed_on: period, ordered_on: period - 1)
      end

      it "attributes the commission by disbursement date", :aggregate_failures do
        described_class.call(period.prev_month)
        described_class.call(period)

        expect(merchant.monthly_fees.find_by!(period: period.prev_month).amount_cents).to eq(500)
        expect(monthly_fee.amount_cents).to eq(400)
      end
    end

    context "when a WEEKLY disbursement crosses a calendar-month boundary" do
      let(:merchant) do
        create(:merchant, disbursement_frequency: "WEEKLY", minimum_monthly_fee_cents: 500)
      end
      let(:disbursement) { create(:disbursement, merchant:, disbursed_on: period + 3) }

      before do
        create(:merchant_order, merchant:, disbursement:, ordered_on: period - 3, fee_cents: 100)
        create(:merchant_order, merchant:, disbursement:, ordered_on: period + 3, fee_cents: 150)
      end

      it "attributes every commission to the disbursement month" do
        described_class.call(period)

        expect(monthly_fee.amount_cents).to eq(250)
      end
    end

    context "when an order has a persisted commission" do
      before do
        create_commission(125, disbursed_on: period, amount_cents: 10_000)
        allow(Commissions::Calculator).to receive(:call)
      end

      it "uses the historical value without recalculating it", :aggregate_failures do
        described_class.call(period)

        expect(monthly_fee.amount_cents).to eq(375)
        expect(Commissions::Calculator).not_to have_received(:call)
      end
    end

    context "when monthly fees are processed" do
      let!(:order) { create_commission(125, disbursed_on: period, amount_cents: 10_000) }

      it "does not modify the merchant order or its commission" do
        original_attributes = order.attributes

        described_class.call(period)

        expect(order.reload.attributes).to eq(original_attributes)
      end
    end

    context "when the same month is reprocessed" do
      let!(:order) { create_commission(100, disbursed_on: period) }

      it "updates the existing monthly fee without creating a duplicate", :aggregate_failures do
        described_class.call(period)
        order.update!(fee_cents: 200)

        described_class.call(period)

        expect(merchant.monthly_fees.where(period:).count).to eq(1)
        expect(monthly_fee.amount_cents).to eq(300)
      end
    end

    context "when the period is not the first day of a month" do
      it "rejects the unsupported representation" do
        expect { described_class.call(Date.new(2026, 2, 2)) }
          .to raise_error(ArgumentError, /first day/)
      end
    end
  end

  def create_commission(fee_cents, disbursed_on:, ordered_on: disbursed_on, amount_cents: 10_229)
    disbursement = create(:disbursement, merchant:, disbursed_on:)
    create(:merchant_order, merchant:, disbursement:, ordered_on:, amount_cents:, fee_cents:)
  end

  def monthly_fee
    merchant.monthly_fees.find_by!(period:)
  end
end
