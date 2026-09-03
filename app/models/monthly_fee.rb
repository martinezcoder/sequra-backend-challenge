# frozen_string_literal: true

# The resulting minimum fee for one merchant and calendar month.
class MonthlyFee < ActiveRecord::Base
  belongs_to :merchant

  before_validation :normalize_period

  private

  def normalize_period
    self.period = period.beginning_of_month if period
  end
end
