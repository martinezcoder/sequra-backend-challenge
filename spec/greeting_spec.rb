# frozen_string_literal: true

require "spec_helper"

RSpec.describe Greeting do
  describe "#message" do
    it "returns the environment readiness message" do
      expect(described_class.new.message).to eq("Ruby environment is ready!")
    end
  end
end
