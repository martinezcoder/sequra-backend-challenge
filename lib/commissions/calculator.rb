# frozen_string_literal: true

# Commission calculation domain.
module Commissions
  # Calculates an order commission in integer cents.
  class Calculator
    BASIS_POINTS_PER_UNIT = 10_000

    def self.call(amount_cents)
      rate = Rules.rule_for(amount_cents).fetch(:rate_basis_points)

      (amount_cents * rate).ceildiv(BASIS_POINTS_PER_UNIT)
    end
  end
end
