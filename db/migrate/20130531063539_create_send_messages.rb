class CreateSendMessages < ActiveRecord::Migration
  def change
    create_table :send_messages do |t|
      t.string  :sender_id
      t.string :message
      t.timestamps
    end
  end
end
