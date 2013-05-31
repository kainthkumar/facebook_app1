namespace :fb_graph do
  desc "update friend relationship table"
  task :find_friends => :environment do
  	 @users = User.find(:all).each do |user|
  	   begin
	      	user.get_friends_from_fb
   	    rescue RestClient::RequestFailed => e
		      Rails.logger.error "#{e.response} user #{user.id}"
		    rescue Exception => e
		      Rails.logger.error "#{e.message} user #{user.id}"
		    end
   	 end
  end
end