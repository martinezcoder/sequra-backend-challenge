# frozen_string_literal: true

require "spec_helper"

RSpec.describe Disbursements::Backfill do
  describe ".call" do
    let(:first_order_date) { Date.new(2026, 8, 30) }
    let(:last_order_date) { Date.new(2026, 9, 3) }
    let(:processed_dates) { [] }

    before do
      allow(Disbursements::Process).to receive(:call) { |date| processed_dates << date }
    end

    context "when merchant orders exist" do
      before do
        create(:merchant_order, ordered_on: last_order_date)
        create(:merchant_order, ordered_on: first_order_date)
        described_class.call
      end

      it "begins processing on the earliest order date" do
        expect(processed_dates.first).to eq(first_order_date)
      end

      it "continues processing through six days after the latest order date" do
        expect(processed_dates.last).to eq(last_order_date + 6)
      end

      it "delegates every calendar date in the processing range" do
        expect(processed_dates).to eq((first_order_date..(last_order_date + 6)).to_a)
      end
    end

    context "when there are no merchant orders" do
      it "does not process any dates" do
        described_class.call

        expect(Disbursements::Process).not_to have_received(:call)
      end
    end
  end
end
