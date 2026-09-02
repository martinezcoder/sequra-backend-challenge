# frozen_string_literal: true

# Creates dated disbursements and enforces their idempotency keys.
class CreateDisbursements < ActiveRecord::Migration[8.1]
  def change
    create_table :disbursements do |table|
      table.string :reference, null: false
      table.references :merchant, null: false, foreign_key: true
      table.date :disbursed_on, null: false
    end

    add_index :disbursements, :reference, unique: true
    add_index :disbursements, %i[merchant_id disbursed_on], unique: true
  end
end
