class UserStocks < ActiveRecord::Base
	attr_accessible :stock, :shares, :stock_id
end