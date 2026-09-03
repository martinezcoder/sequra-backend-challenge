# frozen_string_literal: true

require "factory_bot"
require "stringio"
require_relative "../config/environment"

FactoryBot.definition_file_paths = [File.join(__dir__, "factories")]
FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.around(:each, :silence_stderr) do |example|
    original_stderr = $stderr
    $stderr = StringIO.new
    example.run
  ensure
    $stderr = original_stderr
  end

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
