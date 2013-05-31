class CreateEventProperties < ActiveRecord::Migration
  def change
    create_table :event_properties do |t|
      t.integer :event_id
      t.string :name
      t.string :value
    end
  end
end
