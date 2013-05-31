class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :facebook_token
      t.string :stockyard_name
      t.date :date_token_updated
      t.timestamps
    end
  end
end
