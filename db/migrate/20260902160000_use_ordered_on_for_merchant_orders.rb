# frozen_string_literal: true

# Represents the source order date with its actual calendar-date precision.
class UseOrderedOnForMerchantOrders < ActiveRecord::Migration[8.1]
  def up
    rename_column :merchant_orders, :created_at, :ordered_on
    change_column :merchant_orders, :ordered_on, :date, null: false, using: "ordered_on::date"
  end

  def down
    change_column :merchant_orders, :ordered_on, :datetime, null: false, using: "ordered_on::timestamp"
    rename_column :merchant_orders, :ordered_on, :created_at
  end
end
