# frozen_string_literal: true

require "spec_helper"

RSpec.describe Commissions::Rules do
  describe ".rule_for" do
    it "returns the 1.00% rule below 50 euros" do
      expect(described_class.rule_for(4_999)).to include(rate_basis_points: 100)
    end

    it "returns the 0.95% rule at exactly 50 euros" do
      expect(described_class.rule_for(5_000)).to include(rate_basis_points: 95)
    end

    it "returns the 0.95% rule between 50 and 300 euros" do
      expect(described_class.rule_for(10_000)).to include(rate_basis_points: 95)
    end

    it "returns the 0.85% rule at exactly 300 euros" do
      expect(described_class.rule_for(30_000)).to include(rate_basis_points: 85)
    end

    it "returns the 0.85% rule above 300 euros" do
      expect(described_class.rule_for(40_000)).to include(rate_basis_points: 85)
    end
  end
end
