class UserApplication < ActiveRecord::Base
  # attr_accessible :title, :body
  
  def self.cron_demo
   
   users=User.find(:all)
   puts "the user count is #{users.count}"
  end
  
  def self.conso
    puts "i am here"
  end
end
