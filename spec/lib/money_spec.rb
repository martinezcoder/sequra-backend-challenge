# frozen_string_literal: true

require "spec_helper"

RSpec.describe Money do
  describe ".from_cents" do
    it "preserves an integer-cent amount for presentation" do
      expect(described_class.from_cents(1_029).to_s).to eq("10.29")
    end
  end

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

    context "when the input is invalid" do
      it "raises an error" do
        expect { described_class.from_euros("invalid") }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#to_s" do
    it "renders zero cents with two decimal places" do
      expect(described_class.from_euros("0.0").to_s).to eq("0.00")
    end

    it "renders whole euro amounts with two decimal places" do
      expect(described_class.from_euros("15.0").to_s).to eq("15.00")
    end

    it "renders values containing cents" do
      expect(described_class.from_euros("102.29").to_s).to eq("102.29")
    end
  end
end
