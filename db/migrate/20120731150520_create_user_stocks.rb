class CreateUserStocks < ActiveRecord::Migration
  def change
    create_table :user_stocks do |t|
      t.string :user_id
      t.string :stock
      t.integer :shares
      t.string :type_stock
    end
  end
end
