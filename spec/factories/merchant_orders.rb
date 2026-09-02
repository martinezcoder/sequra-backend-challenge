# frozen_string_literal: true

FactoryBot.define do
  factory :merchant_order do
    sequence(:external_id) { |number| format("order_%012d", number) }
    merchant
    amount_cents { 10_229 }
    ordered_on { Date.new(2023, 2, 1) }
  end
end
