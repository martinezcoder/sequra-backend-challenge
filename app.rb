# frozen_string_literal: true

require_relative "config/environment"

ActiveRecord::Base.connection.execute("SELECT 1")
puts "Ruby environment is ready!"
