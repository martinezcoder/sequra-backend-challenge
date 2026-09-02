# frozen_string_literal: true

# Creates orders supplied by merchants and links them to their persisted merchant.
class CreateMerchantOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :merchant_orders do |table|
      table.string :external_id, null: false
      table.references :merchant, null: false, foreign_key: true
      table.integer :amount_cents, null: false
      table.datetime :created_at, null: false
    end

    add_index :merchant_orders, :external_id, unique: true
  end
end
