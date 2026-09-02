# frozen_string_literal: true

# An externally supplied order associated with its resolved merchant.
class MerchantOrder < ActiveRecord::Base
  belongs_to :disbursement, optional: true
  belongs_to :merchant

  validate :disbursement_cannot_be_reassigned

  private

  def disbursement_cannot_be_reassigned
    return unless will_save_change_to_disbursement_id? && disbursement_id_in_database.present?

    errors.add(:disbursement, "cannot be changed once assigned")
  end
end
