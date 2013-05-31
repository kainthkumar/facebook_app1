 namespace :userstock_snapshot do
  desc "Create User Stock SnapShot"
  task :generate => :environment do
  	@users = User.find(:all)
  	@users.each do |user|
  		begin
	  		user.model_doc = user.get_doc
	  		stocks = []
	  		date = Date.today
		  	if user.model_doc
     
          #get all ids from stocks if the user has maps elements
          user.model_doc.map.each do |obj_key, obj_value|

            if obj_value["transparent"].nil? && obj_value["shares"] != 0
            	obj_value["type"] = "purchased"
            elsif !obj_value["transparent"].nil?
            	obj_value["type"] = "watched"
            end
    				stocks.push(obj_value)

        end if user.model_doc.map
      	
      	if !stocks.empty?
      		event = Event.new()
      		event.user_id = user.id
      		event.date = date
      		event.event = "stock_report"
      		event.save()

      		stocks.each do |stock|
      			
	          type_property = event.event_properties.new()
	          type_property.name = "type"
	          type_property.value = stock["type"] 
	          type_property.save

	          stock_property = event.event_properties.new()
	          stock_property.name = "stock"
	          stock_property.value = stock["stock_symbol"]
	          stock_property.save

	          shares_property = event.event_properties.new()
	          shares_property.name = "shares"
	          shares_property.value = stock["shares"].nil? ? 0 : stock["shares"]
	          shares_property.save

      		end
      	end


      end

	  	rescue Exception => e
	  		puts  "#{e.message} user #{user.id}"
		    Rails.logger.error "#{e.message} user #{user.id}"
		  end
  	end
  end
end
