# frozen_string_literal: true

# Merchant reference data imported from the external source.
class Merchant < ActiveRecord::Base
  has_many :disbursements
  has_many :merchant_orders
  has_many :monthly_fees
end
