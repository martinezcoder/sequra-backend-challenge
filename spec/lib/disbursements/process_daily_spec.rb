# frozen_string_literal: true

require "spec_helper"

RSpec.describe Disbursements::ProcessDaily do
  let(:processing_date) { Date.new(2023, 2, 1) }
  let!(:daily_merchants) do
    [
      create(:merchant, disbursement_frequency: "DAILY"),
      create(:merchant, disbursement_frequency: "DAILY")
    ]
  end
  let!(:weekly_merchant) { create(:merchant, disbursement_frequency: "WEEKLY") }

  before do
    allow(Disbursements::ProcessMerchant).to receive(:call)
    described_class.call(processing_date)
  end

  it "delegates each DAILY merchant and date to the merchant processor" do
    daily_merchants.each do |merchant|
      expect(Disbursements::ProcessMerchant).to have_received(:call).with(merchant, processing_date)
    end
  end

  it "does not delegate merchants with another frequency" do
    expect(Disbursements::ProcessMerchant).not_to have_received(:call).with(weekly_merchant, processing_date)
  end
end
