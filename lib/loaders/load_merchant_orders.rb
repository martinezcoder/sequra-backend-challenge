# frozen_string_literal: true

# Synchronizes merchant orders atomically from their external CSV source.
class LoadMerchantOrders
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
      # This is important to know that first line is line 2
      CSV.foreach(@path, headers: true, col_sep: ";").with_index(2) do |row, line|
        import(row, line)
      end
    end
  end

  private

  def import(row, line)
    merchant = Merchant.find_by!(reference: row["merchant_reference"])
    merchant_order = MerchantOrder.find_or_initialize_by(external_id: row["id"])
    merchant_order.assign_attributes(merchant_order_attributes(row, merchant))
    merchant_order.save!
  rescue StandardError => e
    report_failure(line, row, e)
    raise
  end

  def merchant_order_attributes(row, merchant)
    {
      merchant:,
      amount_cents: Money.from_euros(row["amount"]).cents,
      created_at: row["created_at"]
    }
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
