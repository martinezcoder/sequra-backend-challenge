# frozen_string_literal: true

require "spec_helper"

RSpec.describe Commissions::Calculator do
  describe ".call" do
    it "calculates a 1.00% fee below 50 euros" do
      expect(described_class.call(4_999)).to eq(50)
    end

    it "calculates a 0.95% fee at exactly 50 euros" do
      expect(described_class.call(5_000)).to eq(48)
    end

    it "calculates a 0.95% fee between 50 and 300 euros" do
      expect(described_class.call(10_000)).to eq(95)
    end

    it "calculates a 0.85% fee at exactly 300 euros" do
      expect(described_class.call(30_000)).to eq(255)
    end

    it "calculates a 0.85% fee above 300 euros" do
      expect(described_class.call(40_000)).to eq(340)
    end

    it "rounds a fractional-cent fee upward" do
      expect(described_class.call(101)).to eq(2)
    end
  end
end
