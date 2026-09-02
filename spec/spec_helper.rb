# frozen_string_literal: true

require "factory_bot"
require_relative "../config/environment"
require_relative "../lib/greeting"

FactoryBot.definition_file_paths = [File.join(__dir__, "factories")]
FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
