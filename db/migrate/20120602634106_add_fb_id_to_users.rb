class AddFbIdToUsers < ActiveRecord::Migration
   def change
    add_column :users, :fb_id, :text
  end
end

