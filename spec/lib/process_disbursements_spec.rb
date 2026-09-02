# frozen_string_literal: true

require "spec_helper"

RSpec.describe ProcessDisbursements do
  describe ".call" do
    let(:processing_date) { Date.new(2026, 9, 3) }
    let(:calls) { [] }

    before do
      allow(ProcessDailyDisbursements).to receive(:call) do |date|
        calls << [:daily, date]
      end
      allow(ProcessWeeklyDisbursements).to receive(:call) do |date|
        calls << [:weekly, date]
      end
    end

    it "runs DAILY and WEEKLY processing sequentially for the requested date" do
      described_class.call(processing_date)

      expect(calls).to eq([[:daily, processing_date], [:weekly, processing_date]])
    end
  end
end
