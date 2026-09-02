# frozen_string_literal: true

require "tempfile"
require "spec_helper"

RSpec.describe LoadMerchantOrders do
  let(:csv_file) { Tempfile.new(["merchant_orders", ".csv"]) }

  after do
    csv_file.close!
  end

  describe ".call" do
    let(:merchant) { create(:merchant, reference: "padberg_group") }
    let(:external_id) { "e653f3e14bc4" }
    let(:valid_row) { [external_id, merchant.reference, "102.29", "2023-02-01"] }

    context "when the order does not exist" do
      let(:expected_attributes) do
        { merchant:, amount_cents: 10_229, ordered_on: Date.new(2023, 2, 1) }
      end

      before do
        write_csv(valid_row)
      end

      it "imports the order and maps its source values" do
        described_class.call(csv_file.path)

        expect(MerchantOrder.find_by!(external_id:)).to have_attributes(expected_attributes)
      end
    end

    context "when the same file is imported more than once" do
      before do
        write_csv(valid_row)
      end

      it "does not create duplicate orders" do
        2.times { described_class.call(csv_file.path) }

        expect(MerchantOrder.where(external_id:).count).to eq(1)
      end
    end

    context "when the order already exists" do
      before do
        create(:merchant_order, external_id:, merchant:, amount_cents: 500)
        write_csv(valid_row)
      end

      it "updates the order with its source data" do
        described_class.call(csv_file.path)

        expect(MerchantOrder.find_by!(external_id:).amount_cents).to eq(10_229)
      end
    end

    context "when the order has already been disbursed" do
      let(:expected_attributes) do
        {
          amount_cents: 10_229,
          ordered_on: Date.new(2023, 2, 1),
          disbursement: merchant.disbursements.first,
          fee_cents: 102
        }
      end

      before do
        disbursement = create(:disbursement, merchant:)
        create(
          :merchant_order,
          external_id:,
          merchant:,
          disbursement:,
          fee_cents: 102,
          amount_cents: 500,
          ordered_on: Date.new(2023, 1, 1)
        )
        write_csv(valid_row)
      end

      it "updates source attributes without changing its disbursement state" do
        described_class.call(csv_file.path)

        expect(MerchantOrder.find_by!(external_id:)).to have_attributes(expected_attributes)
      end
    end

    context "when the merchant reference cannot be resolved" do
      let(:unresolved_row) { ["20b674c93ea6", "missing_merchant", "433.21", "2023-02-02"] }

      before do
        write_csv(unresolved_row)
      end

      it "raises an error instead of skipping the order" do
        expect { described_class.call(csv_file.path) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when a later row is invalid after a new order" do
      let(:unresolved_row) { ["20b674c93ea6", "missing_merchant", "433.21", "2023-02-02"] }

      before do
        stub_const("LoadMerchantOrders::BATCH_SIZE", 1)
        write_csv(valid_row, unresolved_row)
      end

      it "reports the failing CSV line and row" do
        expect { described_class.call(csv_file.path) }
          .to output(/CSV line 3:.*missing_merchant.*ActiveRecord::RecordNotFound/).to_stderr
          .and raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises an error and rolls back the create", :aggregate_failures do
        expect { described_class.call(csv_file.path) }
          .to raise_error(ActiveRecord::RecordNotFound)

        expect(MerchantOrder.exists?(external_id:)).to be(false)
      end
    end

    context "when a later row is invalid after an existing order" do
      let(:unresolved_row) { ["20b674c93ea6", "missing_merchant", "433.21", "2023-02-02"] }

      before do
        stub_const("LoadMerchantOrders::BATCH_SIZE", 1)
        create(:merchant_order, external_id:, merchant:, amount_cents: 500)
        write_csv(valid_row, unresolved_row)
      end

      it "raises an error and rolls back the update", :aggregate_failures do
        expect { described_class.call(csv_file.path) }
          .to raise_error(ActiveRecord::RecordNotFound)

        expect(MerchantOrder.find_by!(external_id:).amount_cents).to eq(500)
      end
    end

    context "when the final batch is smaller than the batch size" do
      let(:additional_rows) do
        [
          ["20b674c93ea6", merchant.reference, "433.21", "2023-02-02"],
          ["0b73fb1d3332", merchant.reference, "194.37", "2023-02-03"]
        ]
      end

      before do
        stub_const("LoadMerchantOrders::BATCH_SIZE", 2)
        write_csv(valid_row, *additional_rows)
      end

      it "persists the final partial batch" do
        described_class.call(csv_file.path)

        external_ids = [external_id, *additional_rows.map(&:first)]
        expect(MerchantOrder.where(external_id: external_ids).count).to eq(3)
      end
    end
  end

  def write_csv(*rows)
    CSV.open(csv_file.path, "w", col_sep: ";") do |csv|
      csv << %w[id merchant_reference amount created_at]
      rows.each { |row| csv << row }
    end
  end
end
