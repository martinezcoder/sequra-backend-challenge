# frozen_string_literal: true

require "spec_helper"

RSpec.describe MerchantOrder do
  subject(:merchant_order) { create(:merchant_order) }

  it "belongs to its merchant" do
    expect(merchant_order.merchant.merchant_orders).to include(merchant_order)
  end

  context "when the order has not been disbursed" do
    it "persists without a disbursement" do
      expect(merchant_order.disbursement).to be_nil
    end
  end

  context "when the order has been disbursed" do
    subject(:merchant_order) do
      create(:merchant_order, merchant:, disbursement:, fee_cents: 102)
    end

    let(:merchant) { create(:merchant) }
    let(:disbursement) { create(:disbursement, merchant:) }

    it "belongs to the disbursement" do
      expect(merchant_order.disbursement).to eq(disbursement)
    end

    it "is available from the disbursement" do
      expect(disbursement.merchant_orders).to include(merchant_order)
    end

    it "persists its commission fee in cents" do
      expect(merchant_order.reload.fee_cents).to eq(102)
    end
  end

  context "when an external identifier is duplicated" do
    it "rejects the duplicate at the database level" do
      expect do
        create(:merchant_order, external_id: merchant_order.external_id)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
