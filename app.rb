# frozen_string_literal: true

require_relative "lib/greeting"
require_relative "config/environment"

ActiveRecord::Base.connection.execute("SELECT 1")
puts Greeting.new.message
