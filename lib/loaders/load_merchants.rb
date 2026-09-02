# frozen_string_literal: true

require "csv"
require_relative "../../config/environment"

# Synchronizes merchant reference data atomically from its external CSV source.
class LoadMerchants
  def self.call(path)
    new(path).call
  end

  def initialize(path)
    @path = path
  end

  # Imports the entire CSV in a single transaction.
  # Any row failure aborts the import and rolls back all changes.
  def call
    ActiveRecord::Base.transaction(requires_new: true) do
      # Start at 2 because line 1 contains the CSV headers.
      CSV.foreach(@path, headers: true, col_sep: ";").with_index(2) do |row, line|
        import(row, line)
      end
    end
  end

  private

  def import(row, line)
    merchant = Merchant.find_or_initialize_by(external_id: row["id"])
    merchant.assign_attributes(merchant_attributes(row))
    merchant.save!
  rescue StandardError => e
    report_failure(line, row, e)
    raise
  end

  def merchant_attributes(row)
    {
      reference: row["reference"],
      email: row["email"],
      live_on: row["live_on"],
      disbursement_frequency: row["disbursement_frequency"],
      minimum_monthly_fee_cents: Money.from_euros(row["minimum_monthly_fee"]).cents
    }
  end

  def report_failure(line, row, error)
    warn "Merchant import failed at CSV line #{line}: #{safe_row(row)}; " \
         "#{error.class}: #{error.message}"
  end

  def safe_row(row)
    row.to_h.inspect
  rescue StandardError
    "<row unavailable>"
  end
end
