# frozen_string_literal: true

FactoryBot.define do
  factory :disbursement do
    sequence(:reference) { |number| format("DISB%012d", number) }
    merchant
    disbursed_on { Date.new(2023, 2, 1) }
  end
end
