class UserApplication < ActiveRecord::Base
  # attr_accessible :title, :body
  
  def self.cron_demo
    sender_chat_id = "-100002340314497@chat.facebook.com"
    message_subject = "message subject"
     receiverss=["1260219856","100000080158727","100000590727241","100000973512268","100001239671137","100001575698095"]
   receivers=SendMessage.find(:all)
  unless receivers.empty?
    receivers.each_with_index do |receiver,index|
       user = User.find_by_id(receiver.sender_id)
       unless user.nil?
       receiver_chat_id = "-#{user.fb_id}@chat.facebook.com"
       jabber_message = Jabber::Message.new(receiver_chat_id, "Hello this is cron mesage")
        jabber_message.subject = message_subject
        client = Jabber::Client.new(Jabber::JID.new(sender_chat_id))
        client.connect
        # puts jabber_message
        client.auth_sasl(Jabber::SASL::XFacebookPlatform.new(client,'641206265895621', 'CAAJHLHe02sUBAP0f1PGtUssv32HrNEg0byjO6mYesZBGWGqvAtf3V6lzn6sjTUJcNNgdRuaeGN3fY76V84UaNCEXZC8kbYGJ7QOqWhuuTXxQpoeJrZA2GnvcHZC1gqtVVHp5Iy5ekB4C7ZBxV11UC','e81cd8aa1272a4b3a17e3ac0824b07dc'), nil)
        client.send(jabber_message) 
        client.close
        puts client
        receiver.destroy
      end
    end
  end
   
  end
  
  def self.conso
    puts "i am here"
  end
end
