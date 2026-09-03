# frozen_string_literal: true

require "open3"
require "spec_helper"

RSpec.describe Disbursements::Process do
  subject(:result) { run_command(*arguments) }

  context "when the date is missing" do
    let(:arguments) { [] }
    let(:expected_result) do
      [
        "",
        /Usage:.*process_disbursements YYYY-MM-DD/,
        an_object_having_attributes(success?: false)
      ]
    end

    it "fails with usage instructions" do
      expect(result).to match(expected_result)
    end
  end

  context "when the date is invalid" do
    let(:arguments) { ["2026-02-30"] }
    let(:expected_result) do
      [
        "",
        /Invalid date:.*expected YYYY-MM-DD/,
        an_object_having_attributes(success?: false)
      ]
    end

    it "fails with the expected date format" do
      expect(result).to match(expected_result)
    end
  end

  def run_command(*)
    executable = File.expand_path("../../../bin/process_disbursements", __dir__)
    Open3.capture3(Gem.ruby, executable, *)
  end
end
