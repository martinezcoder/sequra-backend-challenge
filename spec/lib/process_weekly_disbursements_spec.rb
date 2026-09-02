# frozen_string_literal: true

require "spec_helper"

RSpec.describe ProcessWeeklyDisbursements do
  let(:processing_date) { Date.new(2026, 9, 3) }
  let!(:matching_merchant) do
    create(:merchant, disbursement_frequency: "WEEKLY", live_on: Date.new(2023, 2, 2))
  end
  let!(:different_weekday_merchant) do
    create(:merchant, disbursement_frequency: "WEEKLY", live_on: Date.new(2023, 2, 1))
  end
  let!(:daily_merchant) do
    create(:merchant, disbursement_frequency: "DAILY", live_on: Date.new(2023, 2, 2))
  end

  before do
    allow(ProcessMerchantDisbursement).to receive(:call)
    described_class.call(processing_date)
  end

  it "delegates a WEEKLY merchant whose weekday matches" do
    expect(ProcessMerchantDisbursement).to have_received(:call).with(matching_merchant, processing_date)
  end

  it "does not delegate a WEEKLY merchant from another weekday" do
    expect(ProcessMerchantDisbursement)
      .not_to have_received(:call).with(different_weekday_merchant, processing_date)
  end

  it "does not delegate a DAILY merchant" do
    expect(ProcessMerchantDisbursement).not_to have_received(:call).with(daily_merchant, processing_date)
  end
end
