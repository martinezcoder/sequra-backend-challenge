# frozen_string_literal: true

require_relative "config/environment"
require "active_record/tasks/database_tasks"

ActiveRecord::Tasks::DatabaseTasks.root = Dir.pwd
ActiveRecord::Tasks::DatabaseTasks.db_dir = File.join(Dir.pwd, "db")
ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [File.join(Dir.pwd, "db/migrate")]
ActiveRecord::Tasks::DatabaseTasks.env = ENV.fetch("APP_ENV", "development")

task :environment

load "active_record/railties/databases.rake"
