# frozen_string_literal: true

require "spec_helper"

RSpec.describe Merchant do
  subject(:merchant) { create(:merchant, **merchant_attributes) }

  let(:merchant_attributes) do
    {
      external_id: "86312006-4d7e-45c4-9c28-788f4aa68a62",
      reference: "padberg_group",
      email: "info@padberg-group.com",
      live_on: Date.new(2023, 2, 1),
      disbursement_frequency: "DAILY",
      minimum_monthly_fee_cents: 1_500
    }
  end

  let(:persisted_merchant) do
    described_class.find(merchant.id)
  end

  it "persists the merchant data" do
    expect(merchant).to have_attributes(merchant_attributes)
  end

  it "persists the fee in integer cents" do
    expect(merchant.minimum_monthly_fee_cents).to be_an(Integer)
  end

  it "rejects duplicate external identifiers at the database level" do
    expect do
      create(:merchant, external_id: merchant.external_id)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "rejects duplicate references at the database level" do
    expect do
      create(:merchant, reference: merchant.reference)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
