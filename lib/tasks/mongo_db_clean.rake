namespace :mongo_db_clean do
  desc "Clean User's Messages"
  task :messages => :environment do
  	total_messages = ENV['top_messages'].nil? ? Rails.configuration.top_messages : ENV['top_messages'].to_i
  	@users = User.find(:all)
  	@users.each do |user|
  		begin
	  		user.model_doc = user.get_doc
		  	model = user.document_to_hash
		  	if !model["messages"].nil?
		  		#sort by sent_date for deleting oldest messages
		  		model["messages"] = model["messages"].sort_by { |k,v| Date.strptime(v["sent_date"], "%Y/%m/%d - %H:%M:%S") }

			  	if model["messages"].length > total_messages
			  		model["messages"].each_with_index do |(k,v), index|
			  			if total_messages >= index+1
			  				user.model_doc.unset("messages.#{k}")
			  			else
			  				break
			  			end
			  		end
			  	end
		  	end
	  	rescue Exception => e
	  		puts  "#{e.message} user #{user.id}"
		    Rails.logger.error "#{e.message} user #{user.id}"
		  end
  	end
  end

  desc "Clean User's notifications"
  task :notifications => :environment do
  	@users = User.find(:all)
  	@users.each do |user|
  		begin
	  		user.model_doc = user.get_doc
	  		
	  		#check if the user already has opened 
	  		#the performace report today
	  		performance_report = user.model_doc["notifications"]["performance_report"]
		  	
		  	user.model_doc.set("notifications",{})

		  	#if so, lets keep the value 
		  	#until next performance report task
		  	user.model_doc.set("notifications.performance_report",true) if performance_report


	  	rescue Exception => e
	  		puts  "#{e.message} user #{user.id}"
		    Rails.logger.error "#{e.message} user #{user.id}"
		  end
  	end
  end
end