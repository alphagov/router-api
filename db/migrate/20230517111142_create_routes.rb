class CreateRoutes < ActiveRecord::Migration[7.0]
  def change
    create_table :routes do |t|
      t.string  :incoming_path
      t.string  :route_type
      t.string  :handler
      t.boolean :disabled, default: false
      t.string  :backend_id
      t.string  :redirect_to
      t.string  :redirect_type
      t.string  :segments_mode
      t.timestamps
    end

    add_index :routes, :incoming_path, unique: true
  end
end
