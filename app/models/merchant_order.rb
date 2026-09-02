# frozen_string_literal: true

# An externally supplied order associated with its resolved merchant.
class MerchantOrder < ActiveRecord::Base
  belongs_to :disbursement, optional: true
  belongs_to :merchant
end
