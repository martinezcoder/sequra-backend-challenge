# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/money"

RSpec.describe Money do
  describe ".from_euros" do
    it "converts zero euros to zero cents" do
      expect(described_class.from_euros("0.0").cents).to eq(0)
    end

    it "converts whole euro values to cents" do
      expect(described_class.from_euros("15.0").cents).to eq(1_500)
    end

    it "converts euro values with cents exactly" do
      expect(described_class.from_euros("102.29").cents).to eq(10_229)
    end

    it "does not lose precision through floating-point conversion" do
      expect(described_class.from_euros("0.29").cents).to eq(29)
    end

    it "rejects invalid monetary input" do
      expect { described_class.from_euros("invalid") }.to raise_error(ArgumentError)
    end
  end

  describe "#to_euros" do
    it "converts zero cents to euros" do
      expect(described_class.from_euros("0.0").to_euros).to eq(BigDecimal("0.0"))
    end

    it "converts whole euro amounts exactly" do
      expect(described_class.from_euros("15.0").to_euros).to eq(BigDecimal("15.0"))
    end

    it "converts amounts containing cents exactly" do
      money = described_class.from_euros("102.29")

      expect(money.to_euros).to eq(BigDecimal("102.29"))
    end

    it "preserves the value through a euros-to-cents-to-euros round trip" do
      money = described_class.from_euros("102.29")

      expect([money.cents, money.to_euros]).to eq([10_229, BigDecimal("102.29")])
    end

    it "returns an exact decimal rather than a floating-point value" do
      expect(described_class.from_euros("0.29").to_euros).to be_a(BigDecimal)
    end
  end
end
