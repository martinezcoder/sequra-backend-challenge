# frozen_string_literal: true

require "bigdecimal"

# Stores integer cents and converts to and from exact euro decimals without
# providing broader monetary operations.
class Money
  EURO_FORMAT = /\A\d+\.\d{1,2}\z/

  attr_reader :cents

  def self.from_euros(value)
    valid = value.is_a?(String) && EURO_FORMAT.match?(value)
    raise ArgumentError, "invalid euro amount" unless valid

    new((BigDecimal(value) * 100).to_i)
  end

  def initialize(cents)
    @cents = cents
  end

  def to_euros
    BigDecimal(cents.to_s) / 100
  end

  private_class_method :new
end
