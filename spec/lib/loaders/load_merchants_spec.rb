# frozen_string_literal: true

require "csv"
require "tempfile"
require "spec_helper"
require_relative "../../../lib/loaders/load_merchants"

RSpec.describe LoadMerchants do
  let(:csv_file) { Tempfile.new(["merchants", ".csv"]) }
  let(:external_id) { "86312006-4d7e-45c4-9c28-788f4aa68a62" }
  let(:valid_row) do
    [external_id, "padberg_group", "info@padberg-group.com", "2023-02-01", "DAILY", "15.0"]
  end
  let(:expected_attributes) do
    {
      reference: "padberg_group",
      email: "info@padberg-group.com",
      live_on: Date.new(2023, 2, 1),
      disbursement_frequency: "DAILY",
      minimum_monthly_fee_cents: 1_500
    }
  end

  after do
    csv_file.close!
  end

  it "imports a merchant and maps its source values" do
    write_csv(valid_row)

    described_class.call(csv_file.path)

    expect(Merchant.find_by!(external_id:)).to have_attributes(expected_attributes)
  end

  it "is idempotent" do
    write_csv(valid_row)

    2.times { described_class.call(csv_file.path) }

    expect(Merchant.where(external_id:).count).to eq(1)
  end

  it "updates a merchant when its source data changes" do
    create(:merchant, external_id:, email: "old@example.com")
    write_csv(valid_row)

    described_class.call(csv_file.path)

    expect(Merchant.find_by!(external_id:).email).to eq("info@padberg-group.com")
  end

  it "rolls back earlier creates when a later row fails" do
    write_csv(valid_row, invalid_row)

    expect { import_ignoring_error }.not_to(change { Merchant.where(external_id:).count })
  end

  it "rolls back earlier updates when a later row fails" do
    merchant = create(:merchant, external_id:, email: "old@example.com")
    write_csv(valid_row, invalid_row)

    expect { import_ignoring_error }.not_to(change { merchant.reload.email })
  end

  it "reports the failing CSV line and row to stderr" do
    write_csv(valid_row, invalid_row)

    expect { described_class.call(csv_file.path) }
      .to output(/CSV line 3:.*invalid_fee.*ArgumentError/).to_stderr
      .and raise_error(ArgumentError)
  end

  it "does not silently skip invalid data" do
    write_csv(invalid_row)

    expect { described_class.call(csv_file.path) }.to raise_error(ArgumentError)
  end

  def invalid_row
    ["d1649242-a612-46ba-82d8-225542bb9576", "invalid", "invalid@example.com",
     "2023-02-02", "WEEKLY", "invalid_fee"]
  end

  def import_ignoring_error
    described_class.call(csv_file.path)
  rescue ArgumentError
    nil
  end

  def write_csv(*rows)
    CSV.open(csv_file.path, "w", col_sep: ";") do |csv|
      csv << %w[id reference email live_on disbursement_frequency minimum_monthly_fee]
      rows.each { |row| csv << row }
    end
  end
end
