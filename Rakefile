# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

Rails.application.load_tasks

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  # Rubocop isn't available in all environments
end

Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task default: %i[rubocop spec]

# This app needs to define a custom function/trigger, which can't
# be represented using a normal db/schema.rb file. However, using
# a db/structure.sql file is inconsistent with our other repos, as
# well as being much less readable. Instead, we primarily use the
# db/schema.rb, and load custom functionality from db/custom_functions.sql.
%w[db:schema:load db:test:prepare].each do |task|
  Rake::Task[task].enhance do
    # Additionally load db/custom_functions.sql
    ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:sql, "db/custom_functions.sql")
  end
end
