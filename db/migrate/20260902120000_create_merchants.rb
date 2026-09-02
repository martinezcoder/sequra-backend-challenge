# frozen_string_literal: true

# Creates the persistence structure for merchants supplied by the source system.
class CreateMerchants < ActiveRecord::Migration[8.1]
  def change
    create_table :merchants do |table|
      table.uuid :external_id
      table.string :reference
      table.string :email
      table.date :live_on
      table.string :disbursement_frequency
      table.integer :minimum_monthly_fee_cents
    end

    add_index :merchants, :external_id, unique: true
    add_index :merchants, :reference, unique: true
  end
end
