# frozen_string_literal: true

# Synchronizes merchant orders atomically from their external CSV source.
class LoadMerchantOrders
  # Limits importer memory without claiming an empirically tuned batch size.
  BATCH_SIZE = 1_000

  def self.call(path)
    new(path).call
  end

  def initialize(path)
    @path = path

    # Keep a lightweight reference-to-id snapshot in memory to avoid querying
    # merchants for each of the ~1.3M imported orders.
    @merchant_ids = Merchant.pluck(:reference, :id).to_h.freeze
  end

  # Imports the entire CSV in a single transaction.
  # Any row failure aborts the import and rolls back all changes.
  def call
    ActiveRecord::Base.transaction(requires_new: true) do
      batch = []

      # Start at 2 because line 1 contains the CSV headers.
      CSV.foreach(@path, headers: true, col_sep: ";").with_index(2) do |row, line|
        batch << attributes(row, line)
        persist(batch) if batch.size >= BATCH_SIZE
      end

      persist(batch)
    end
  end

  private

  attr_reader :merchant_ids

  def attributes(row, line)
    {
      external_id: row["id"],
      merchant_id: merchant_id(row, merchant_ids),
      amount_cents: Money.from_euros(row["amount"]).cents,
      ordered_on: Date.parse(row["created_at"])
    }
  rescue StandardError => e
    report_failure(line, row, e)
    raise
  end

  def merchant_id(row, merchant_ids)
    reference = row["merchant_reference"]
    merchant_ids.fetch(reference) do
      raise ActiveRecord::RecordNotFound, "Couldn't find Merchant with reference #{reference.inspect}"
    end
  end

  def persist(batch)
    return if batch.empty?

    # Bulk upsert avoids millions of model-level database writes. It intentionally
    # bypasses validations and callbacks, so every value must be resolved and
    # normalized before it reaches this persistence boundary.
    MerchantOrder.upsert_all(batch, unique_by: :external_id)
    batch.clear
  end

  def report_failure(line, row, error)
    warn "Merchant order import failed at CSV line #{line}: #{safe_row(row)}; " \
         "#{error.class}: #{error.message}"
  end

  def safe_row(row)
    row.to_h.inspect
  rescue StandardError
    "<row unavailable>"
  end
end
