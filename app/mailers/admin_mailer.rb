class AdminMailer < ActionMailer::Base
  default from: "missionfig@gmail.com"

  def admin_mail(user, message)
  	mail(:to => "#{user.stockyard_name} <#{user.email}>", :subject => "Missionfig", :body => message)
  end
end
