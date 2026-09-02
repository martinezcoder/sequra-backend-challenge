# frozen_string_literal: true

require "spec_helper"

RSpec.describe ProcessDailyMerchantDisbursement do
  let(:processing_date) { Date.new(2023, 2, 1) }
  let(:merchant) { create(:merchant, disbursement_frequency: "DAILY") }

  describe ".call" do
    context "when the merchant has orders on the processing date" do
      let!(:orders) do
        [
          create(:merchant_order, merchant:, amount_cents: 10_229, created_at: Time.utc(2023, 2, 1, 9)),
          create(:merchant_order, merchant:, amount_cents: 43_321, created_at: Time.utc(2023, 2, 1, 18))
        ]
      end

      before do
        described_class.call(merchant, processing_date)
      end

      it "creates one deterministic disbursement for the merchant and date" do
        expect(merchant.disbursements.first).to have_attributes(
          reference: "D20230201M#{merchant.id}",
          disbursed_on: processing_date
        )
      end

      it "associates the eligible orders with the disbursement" do
        expect(orders.map { |order| order.reload.disbursement }).to all(eq(merchant.disbursements.first))
      end

      it "persists the one-percent fees rounded up to cents" do
        expect(orders.map { |order| order.reload.fee_cents }).to eq([103, 434])
      end
    end

    context "when an order belongs to another date" do
      let!(:order) do
        create(:merchant_order, merchant:, created_at: Time.utc(2023, 2, 2))
      end

      before do
        described_class.call(merchant, processing_date)
      end

      it "does not include the order in a disbursement" do
        expect(order.reload.disbursement).to be_nil
      end
    end

    context "when an order belongs to another merchant" do
      let(:other_merchant) { create(:merchant, disbursement_frequency: "DAILY") }
      let!(:other_order) do
        create(:merchant_order, merchant: other_merchant, created_at: Time.utc(2023, 2, 1))
      end

      before do
        create(:merchant_order, merchant:, created_at: Time.utc(2023, 2, 1))
        described_class.call(merchant, processing_date)
      end

      it "does not include the other merchant's order" do
        expect(other_order.reload.disbursement).to be_nil
      end
    end

    context "when the merchant has no orders on the processing date" do
      it "does not create an empty disbursement" do
        described_class.call(merchant, processing_date)

        expect(merchant.disbursements).to be_empty
      end
    end

    context "when the date is processed more than once" do
      let!(:order) do
        create(:merchant_order, merchant:, amount_cents: 10_229, created_at: Time.utc(2023, 2, 1))
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
      MerchantOrder.where(merchant:, created_at: processing_date...processing_date.next_day)
    end
    let!(:orders) do
      [
        create(:merchant_order, merchant:, created_at: Time.utc(2023, 2, 1, 9)),
        create(:merchant_order, merchant:, created_at: Time.utc(2023, 2, 1, 18))
      ]
    end

    before do
      allow(eligible_orders).to receive(:find_each).and_yield(orders.first).and_yield(orders.last)
      allow(MerchantOrder).to receive(:where)
        .with(merchant:, created_at: processing_date...processing_date.next_day)
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
