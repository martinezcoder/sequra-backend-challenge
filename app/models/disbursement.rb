# frozen_string_literal: true

# A dated payment made to a merchant.
class Disbursement < ActiveRecord::Base
  belongs_to :merchant
end
