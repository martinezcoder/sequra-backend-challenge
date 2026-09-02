# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    sequence(:external_id) { |number| format("00000000-0000-4000-8000-%012d", number) }
    sequence(:reference) { |number| "merchant_#{number}" }
    email { "merchant@example.com" }
    live_on { Date.new(2023, 2, 1) }
    disbursement_frequency { "DAILY" }
    minimum_monthly_fee_cents { 1_500 }
  end
end
