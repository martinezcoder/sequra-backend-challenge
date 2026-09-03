# frozen_string_literal: true

FactoryBot.define do
  factory :monthly_fee do
    merchant
    period { Date.new(2026, 1, 1) }
    amount_cents { 100 }
  end
end
