class CreateBackends < ActiveRecord::Migration[7.0]
  def change
    create_table :backends do |t|
      t.string :backend_id
      t.string :backend_url
      t.timestamps
    end

    add_index :backends, :backend_id, unique: true
  end
end
