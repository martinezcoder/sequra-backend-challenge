# frozen_string_literal: true

require "spec_helper"

RSpec.describe Disbursement do
  subject(:disbursement) { create(:disbursement) }

  it "belongs to its merchant" do
    expect(disbursement.merchant.disbursements).to include(disbursement)
  end

  it "persists its disbursement date" do
    expect(disbursement.reload.disbursed_on).to eq(Date.new(2023, 2, 1))
  end

  context "when a reference is duplicated" do
    it "rejects the duplicate at the database level" do
      expect do
        create(:disbursement, reference: disbursement.reference)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  context "when a merchant already has a disbursement on the same date" do
    it "rejects the duplicate at the database level" do
      expect do
        create(:disbursement, merchant: disbursement.merchant, disbursed_on: disbursement.disbursed_on)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
