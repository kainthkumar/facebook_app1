namespace :notify do
  desc "Send Daily Report"
  task :daily_report => :environment do
  	@users = User.find(:all)
  	@users.each do |user|
  		begin
	  		user.model_doc = user.get_doc
		  	report_d = DailyReport.where(user_id: user.id).first()
		  	if !report_d.nil?
		  		ReportMailer.daily_report(user,report_d).deliver!
		  	end
	  	rescue Exception => e
	  		puts  "#{e.message} user #{user.id}"
		    Rails.logger.error "#{e.message} user #{user.id}"
		  end
  	end
  end
end
