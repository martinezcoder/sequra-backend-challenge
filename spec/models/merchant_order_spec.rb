# frozen_string_literal: true

require "spec_helper"

RSpec.describe MerchantOrder do
  subject(:merchant_order) { create(:merchant_order) }

  it "belongs to its merchant" do
    expect(merchant_order.merchant.merchant_orders).to include(merchant_order)
  end

  context "when an external identifier is duplicated" do
    it "rejects the duplicate at the database level" do
      expect do
        create(:merchant_order, external_id: merchant_order.external_id)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
