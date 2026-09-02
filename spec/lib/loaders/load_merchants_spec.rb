# frozen_string_literal: true

require "tempfile"
require "spec_helper"

RSpec.describe LoadMerchants do
  let(:csv_file) { Tempfile.new(["merchants", ".csv"]) }

  after do
    csv_file.close!
  end

  describe ".call" do
    let(:external_id) { "86312006-4d7e-45c4-9c28-788f4aa68a62" }
    let(:valid_row) do
      [external_id, "padberg_group", "info@padberg-group.com", "2023-02-01", "DAILY", "15.0"]
    end
    let(:invalid_row) do
      ["d1649242-a612-46ba-82d8-225542bb9576", "invalid", "invalid@example.com",
       "2023-02-02", "WEEKLY", "invalid_fee"]
    end

    context "when the merchant does not exist" do
      let(:expected_attributes) do
        {
          reference: "padberg_group",
          email: "info@padberg-group.com",
          live_on: Date.new(2023, 2, 1),
          disbursement_frequency: "DAILY",
          minimum_monthly_fee_cents: 1_500
        }
      end

      before do
        write_csv(valid_row)
      end

      it "imports the merchant and maps its source values" do
        described_class.call(csv_file.path)

        expect(Merchant.find_by!(external_id:)).to have_attributes(expected_attributes)
      end
    end

    context "when the merchant already exists" do
      before do
        create(:merchant, external_id:, email: "old@example.com")
        write_csv(valid_row)
      end

      it "updates the merchant with its source data" do
        described_class.call(csv_file.path)

        expect(Merchant.find_by!(external_id:).email).to eq("info@padberg-group.com")
      end
    end

    context "when the same file is imported more than once" do
      before do
        write_csv(valid_row)
      end

      it "does not create duplicate merchants" do
        2.times { described_class.call(csv_file.path) }

        expect(Merchant.where(external_id:).count).to eq(1)
      end
    end

    context "when a later CSV row is invalid after a new merchant" do
      before do
        write_csv(valid_row, invalid_row)
      end

      it "reports the failing CSV line and row" do
        expect { described_class.call(csv_file.path) }
          .to output(/CSV line 3:.*invalid_fee.*ArgumentError/).to_stderr
          .and raise_error(ArgumentError)
      end

      it "raises an error and rolls back the create", :aggregate_failures do
        expect { described_class.call(csv_file.path) }.to raise_error(ArgumentError)

        expect(Merchant.exists?(external_id:)).to be(false)
      end
    end

    context "when a later CSV row is invalid after an existing merchant" do
      let!(:merchant) { create(:merchant, external_id:, email: "old@example.com") }

      before do
        write_csv(valid_row, invalid_row)
      end

      it "raises an error and rolls back the update", :aggregate_failures do
        expect { described_class.call(csv_file.path) }.to raise_error(ArgumentError)

        expect(merchant.reload.email).to eq("old@example.com")
      end
    end

    context "when the CSV data is invalid" do
      before do
        write_csv(invalid_row)
      end

      it "raises an error instead of silently skipping the row" do
        expect { described_class.call(csv_file.path) }.to raise_error(ArgumentError)
      end
    end
  end

  def write_csv(*rows)
    CSV.open(csv_file.path, "w", col_sep: ";") do |csv|
      csv << %w[id reference email live_on disbursement_frequency minimum_monthly_fee]
      rows.each { |row| csv << row }
    end
  end
end
