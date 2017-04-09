class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :event_id, null: false
      t.string :type, null: false
      t.string :keyword, null: false
      t.string :title, null: false
      t.string :url, null: false
      t.string :description, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at, null: false
      t.integer :limit, null: false, default: 0
      t.string :address, null: false
      t.string :place, null: false
      t.float :lat
      t.float :lon
      t.string :owner_id, null: false
      t.string :owner_name
    end
    add_index :events, [:event_id, :type], unique: true
    add_index :events, [:started_at, :ended_at]
    add_index :events, :keyword
  end
end
