# frozen_string_literal: true

require "active_record"
require "csv"
require "erb"
require "yaml"

environment = ENV.fetch("APP_ENV", "development")
database_config_path = File.join(__dir__, "database.yml")
database_config = YAML.safe_load(ERB.new(File.read(database_config_path)).result, aliases: true)

ActiveRecord::Base.configurations = database_config
ActiveRecord::Base.establish_connection(environment.to_sym)

require_relative "../app/models/merchant"
require_relative "../lib/greeting"
require_relative "../lib/money"
require_relative "../lib/loaders/load_merchants"
