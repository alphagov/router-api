class CleanupOldIndex < Mongoid::Migration
  def self.up
    # Remove existing index definition so it can be re-created according to the
    # current definition (non-unique)
    Route.collection.indexes.drop(incoming_path: 1, route_type: 1)
  end

  def self.down
  end
end
