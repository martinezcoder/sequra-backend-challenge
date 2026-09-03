# frozen_string_literal: true

# Stores the result of evaluating a merchant's minimum fee for a calendar month.
class CreateMonthlyFees < ActiveRecord::Migration[8.1]
  def change
    create_table :monthly_fees do |table|
      table.references :merchant, null: false, foreign_key: true
      table.date :period, null: false
      table.integer :amount_cents, null: false
    end

    add_index :monthly_fees, %i[merchant_id period], unique: true
  end
end
