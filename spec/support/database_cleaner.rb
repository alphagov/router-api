RSpec.configure do |config|
  DatabaseCleaner.allow_remote_database_url = true

  config.before :each do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
