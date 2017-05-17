RSpec.configure do |config|
  config.before :suite do
    # Ensure we have a blank database with the indexes created
    silence_warnings do
      ::Mongoid::Tasks::Database.create_indexes
    end
  end
end
