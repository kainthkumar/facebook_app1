class ReportMailer < ActionMailer::Base
  default from: "missionfig@gmail.com"

  def daily_report(user,report)
  	@user = user
  	@report_d = report
  	@host_url = Rails.configuration.host_app
  	mail(:to => user.email, :subject => "Daily Report")
  end
  
end
