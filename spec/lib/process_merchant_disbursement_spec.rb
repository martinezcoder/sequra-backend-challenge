# frozen_string_literal: true

require "spec_helper"

RSpec.describe ProcessMerchantDisbursement do
  let(:processing_date) { Date.new(2026, 9, 3) }
  let(:merchant) { create(:merchant, disbursement_frequency: "DAILY") }

  describe ".call" do
    context "when the merchant has eligible orders" do
      let!(:orders) do
        [
          create(:merchant_order, merchant:, amount_cents: 10_229, ordered_on: processing_date),
          create(:merchant_order, merchant:, amount_cents: 43_321, ordered_on: processing_date)
        ]
      end

      before do
        described_class.call(merchant, processing_date)
      end

      it "creates one deterministic disbursement for the merchant and date" do
        expect(merchant.disbursements.first).to have_attributes(
          reference: "D20260903M#{merchant.reference}",
          disbursed_on: processing_date
        )
      end

      it "associates eligible orders with the disbursement" do
        expect(orders.map { |order| order.reload.disbursement }).to all(eq(merchant.disbursements.first))
      end

      it "persists amount-based fees rounded up to cents" do
        expect(orders.map { |order| order.reload.fee_cents }).to eq([98, 369])
      end
    end

    context "when an eligible order belongs to another merchant" do
      let(:other_merchant) { create(:merchant, disbursement_frequency: "DAILY") }
      let!(:other_order) do
        create(:merchant_order, merchant: other_merchant, ordered_on: processing_date)
      end

      before do
        create(:merchant_order, merchant:, ordered_on: processing_date)
        described_class.call(merchant, processing_date)
      end

      it "does not include the other merchant's order" do
        expect(other_order.reload.disbursement).to be_nil
      end
    end

    context "when the merchant has no eligible orders" do
      it "does not create an empty disbursement" do
        described_class.call(merchant, processing_date)

        expect(merchant.disbursements).to be_empty
      end
    end

    context "when the merchant is DAILY" do
      let!(:orders) do
        [
          create(:merchant_order, merchant:, ordered_on: processing_date),
          create(:merchant_order, merchant:, ordered_on: processing_date - 1),
          create(:merchant_order, merchant:, ordered_on: processing_date + 1)
        ]
      end

      before do
        described_class.call(merchant, processing_date)
      end

      it "processes only orders from the processing date" do
        expect(orders.map { |order| !order.reload.disbursement.nil? }).to eq([true, false, false])
      end
    end

    context "when the merchant is WEEKLY" do
      let(:merchant) { create(:merchant, disbursement_frequency: "WEEKLY") }
      let!(:orders) do
        [
          create(:merchant_order, merchant:, ordered_on: processing_date - 6),
          create(:merchant_order, merchant:, ordered_on: processing_date),
          create(:merchant_order, merchant:, ordered_on: processing_date - 7),
          create(:merchant_order, merchant:, ordered_on: processing_date + 1)
        ]
      end

      before do
        described_class.call(merchant, processing_date)
      end

      it "processes the inclusive seven-day window" do
        expect(orders.map { |order| !order.reload.disbursement.nil? }).to eq([true, true, false, false])
      end
    end

    context "when the same merchant and date are processed more than once" do
      let!(:order) do
        create(:merchant_order, merchant:, amount_cents: 10_229, ordered_on: processing_date)
      end

      before do
        2.times { described_class.call(merchant, processing_date) }
      end

      it "keeps one disbursement with the same order and fee", :aggregate_failures do
        expect(merchant.disbursements.count).to eq(1)
        expect(order.reload).to have_attributes(
          disbursement: merchant.disbursements.first,
          fee_cents: 98
        )
      end
    end

    context "when a commission calculator is injected" do
      let(:commission_calculator) { class_double(CommissionCalculator, call: 77) }
      let!(:order) do
        create(:merchant_order, merchant:, amount_cents: 10_229, ordered_on: processing_date)
      end

      it "uses it to determine the persisted fee", :aggregate_failures do
        described_class.call(merchant, processing_date, commission_calculator:)

        expect(commission_calculator).to have_received(:call).with(10_229)
        expect(order.reload.fee_cents).to eq(77)
      end
    end
  end

  describe "merchant consistency" do
    let(:existing_disbursement) do
      create(:disbursement, merchant:, disbursed_on: processing_date - 1)
    end
    let!(:orders) do
      [
        create(:merchant_order, merchant:, ordered_on: processing_date),
        create(
          :merchant_order,
          merchant:,
          ordered_on: processing_date,
          disbursement: existing_disbursement,
          fee_cents: 77
        )
      ]
    end

    it "fails atomically rather than moving an order between disbursements", :aggregate_failures do
      expect { described_class.call(merchant, processing_date) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(Disbursement.exists?(merchant:, disbursed_on: processing_date)).to be(false)
      expect(orders.first.reload).to have_attributes(disbursement: nil, fee_cents: nil)
      expect(orders.last.reload).to have_attributes(disbursement: existing_disbursement, fee_cents: 77)
    end
  end
end
