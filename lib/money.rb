# frozen_string_literal: true

# Stores and calculates monetary values only as integer cents. Its string
# representation is intended solely for presentation.
class Money
  EURO_FORMAT = /\A\d+\.\d{1,2}\z/

  attr_reader :cents

  def self.from_euros(value)
    valid = value.is_a?(String) && EURO_FORMAT.match?(value)
    raise ArgumentError, "invalid euro amount" unless valid

    euros, cents = value.split(".")
    new((euros.to_i * 100) + cents.ljust(2, "0").to_i)
  end

  def initialize(cents)
    @cents = cents
  end

  def to_s
    euros, remaining_cents = cents.divmod(100)
    format("%<euros>d.%<cents>02d", euros:, cents: remaining_cents)
  end

  private_class_method :new
end
