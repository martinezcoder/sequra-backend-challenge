# frozen_string_literal: true

# Resolves the configured commission rule for an order amount.
class CommissionRules
  # Keeping rule lookup behind this boundary lets the source change without
  # affecting commission consumers.
  RULES = [
    { exclusive_upper_bound_cents: 5_000, rate_basis_points: 100 }.freeze,
    { exclusive_upper_bound_cents: 30_000, rate_basis_points: 95 }.freeze,
    { exclusive_upper_bound_cents: nil, rate_basis_points: 85 }.freeze
  ].freeze

  def self.rule_for(amount_cents)
    RULES.find do |rule|
      upper_bound = rule[:exclusive_upper_bound_cents]
      upper_bound.nil? || amount_cents < upper_bound
    end
  end
end
