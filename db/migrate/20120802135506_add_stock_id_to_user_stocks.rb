class AddStockIdToUserStocks < ActiveRecord::Migration
   def change
    add_column :user_stocks, :stock_id, :integer
  end
end
