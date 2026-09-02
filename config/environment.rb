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

require_relative "../app/models/disbursement"
require_relative "../app/models/merchant"
require_relative "../app/models/merchant_order"
require_relative "../lib/greeting"
require_relative "../lib/money"
require_relative "../lib/loaders/load_merchants"
require_relative "../lib/loaders/load_merchant_orders"
require_relative "../lib/commission_rules"
require_relative "../lib/commission_calculator"
require_relative "../lib/process_merchant_disbursement"
require_relative "../lib/process_daily_disbursements"
require_relative "../lib/process_weekly_disbursements"
require_relative "../lib/process_disbursements"
