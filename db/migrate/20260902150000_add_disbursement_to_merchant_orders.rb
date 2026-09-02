# frozen_string_literal: true

# Adds the internal disbursement state assigned after an order is imported.
class AddDisbursementToMerchantOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :merchant_orders, :disbursement, null: true, foreign_key: true
    add_column :merchant_orders, :fee_cents, :integer
  end
end
