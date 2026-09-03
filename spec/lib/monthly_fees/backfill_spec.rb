# frozen_string_literal: true

require "spec_helper"

RSpec.describe MonthlyFees::Backfill do
  describe ".call" do
    let(:first_disbursement_date) { Date.new(2022, 1, 4) }
    let(:last_disbursement_date) { Date.new(2022, 3, 2) }
    let(:processed_periods) { [] }

    before do
      allow(MonthlyFees::Process).to receive(:call) { |period| processed_periods << period }
    end

    context "when completed disbursements exist" do
      before do
        create(:disbursement, disbursed_on: last_disbursement_date)
        create(:disbursement, disbursed_on: first_disbursement_date)
        described_class.call
      end

      it "starts with the month containing the earliest disbursement" do
        expect(processed_periods.first).to eq(Date.new(2022, 1, 1))
      end

      it "ends with the month containing the latest disbursement" do
        expect(processed_periods.last).to eq(Date.new(2022, 3, 1))
      end

      it "processes every intervening month, including months without disbursements" do
        expect(processed_periods).to eq(
          [Date.new(2022, 1, 1), Date.new(2022, 2, 1), Date.new(2022, 3, 1)]
        )
      end

      it "represents every period with the first day of its month" do
        expect(processed_periods.map(&:day)).to all(eq(1))
      end
    end

    context "when there are no completed disbursements" do
      it "does not process any period" do
        described_class.call

        expect(MonthlyFees::Process).not_to have_received(:call)
      end
    end
  end
end
