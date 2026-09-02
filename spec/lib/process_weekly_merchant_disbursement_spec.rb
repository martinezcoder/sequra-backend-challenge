# frozen_string_literal: true

require "spec_helper"

RSpec.describe ProcessWeeklyMerchantDisbursement do
  let(:processing_date) { Date.new(2026, 9, 3) }
  let(:merchant) do
    create(:merchant, disbursement_frequency: "WEEKLY", live_on: Date.new(2023, 2, 2))
  end

  describe ".call" do
    context "when orders fall on both boundaries of the weekly window" do
      let!(:orders) do
        [
          create(:merchant_order, merchant:, amount_cents: 10_229, ordered_on: Date.new(2026, 8, 28)),
          create(:merchant_order, merchant:, amount_cents: 43_321, ordered_on: processing_date)
        ]
      end

      before do
        described_class.call(merchant, processing_date)
      end

      it "creates one deterministic disbursement for the merchant and date" do
        expect(merchant.disbursements.first).to have_attributes(
          reference: "D20260903M#{merchant.id}",
          disbursed_on: processing_date
        )
      end

      it "associates both boundary orders with the disbursement" do
        expect(orders.map { |order| order.reload.disbursement }).to all(eq(merchant.disbursements.first))
      end

      it "persists the one-percent fees rounded up to cents" do
        expect(orders.map { |order| order.reload.fee_cents }).to eq([103, 434])
      end
    end

    context "when orders fall outside the weekly window" do
      let!(:orders) do
        [
          create(:merchant_order, merchant:, ordered_on: Date.new(2026, 8, 27)),
          create(:merchant_order, merchant:, ordered_on: Date.new(2026, 9, 4))
        ]
      end

      before do
        create(:merchant_order, merchant:, ordered_on: processing_date)
        described_class.call(merchant, processing_date)
      end

      it "excludes orders before and after the weekly window" do
        expect(orders.map { |order| order.reload.disbursement }).to all(be_nil)
      end
    end

    context "when the merchant has no orders in the weekly window" do
      it "does not create an empty disbursement" do
        described_class.call(merchant, processing_date)

        expect(merchant.disbursements).to be_empty
      end
    end

    context "when the date is processed more than once" do
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
          fee_cents: 103
        )
      end
    end
  end

  describe "merchant consistency" do
    subject(:processor) { described_class.new(merchant, processing_date) }

    let(:eligible_orders) do
      MerchantOrder.where(merchant:, ordered_on: (processing_date - 6)..processing_date)
    end
    let!(:orders) do
      [
        create(:merchant_order, merchant:, ordered_on: Date.new(2026, 8, 28)),
        create(:merchant_order, merchant:, ordered_on: processing_date)
      ]
    end

    before do
      allow(eligible_orders).to receive(:find_each).and_yield(orders.first).and_yield(orders.last)
      allow(MerchantOrder).to receive(:where)
        .with(merchant:, ordered_on: (processing_date - 6)..processing_date)
        .and_return(eligible_orders)
      allow(orders.last).to receive(:update!).and_raise("processing failed")
    end

    it "rolls back partial processing when an order fails", :aggregate_failures do
      expect { processor.call }.to raise_error("processing failed")
      expect(Disbursement.exists?(merchant:)).to be(false)
      expect(orders.first.reload).to have_attributes(disbursement: nil, fee_cents: nil)
    end
  end
end
