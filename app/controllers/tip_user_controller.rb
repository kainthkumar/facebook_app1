class TipUserController < ApplicationController
  
  require 'rest_client'
  require 'net/http'
  
  respond_to :js, :html,:json
  def send_notification
  
  end

  def send_message
     # puts $PATH
     
    require 'xmpp4r_facebook'
     parsed_json = ActiveSupport::JSON.decode(params[:data])
     message= parsed_json["userMessageData"]['message']
    receiverIds=parsed_json["userMessageData"]['receiver_ids']
    receiverIds.each_with_index do |receiver,index|
     messageObj=SendMessage.new(:sender_id=>receiver,:message=>message)
     messageObj.save
    end
      respond_to do |format|
     format.json {render :json => {:status => "success"}}
  end
    # https://graph.facebook.com/oauth/authorize?type=user_agent&client_id=641206265895621&redirect_uri=http://0.0.0.0:3000/fb-oauth/
    # https://graph.facebook.com/oauth/authorize?response_type=code&client_id=641206265895621&redirect_uri=http://0.0.0.0:3000/fb-oauth/
      # response =  RestClient.get 'https://graph.facebook.com/me/inbox?access_token=CAAJHLHe02sUBAMeCXVciZCT0gncHHRhvDQ71KsaI9ZAGXsjrJ0IGXWoUluPWxrwIhxuMRZCToIdJ528cOg1jYPZC48ZC6dYmeoWpeCpFquZBsZCdkG4Ia1e7aZCuZC6n3eEMF0UNQgxtb6tiOUGOFK538FUDThzpaLpcZD'
      # sender_chat_id = "-100002340314497@chat.facebook.com"
     # # message_body = "message"
    # message_subject = "message subject"
    # # receivessr=["741478597","1260219856","100000080158727","100000590727241","100000973512268","100001239671137","100001575698095"]
   # @facebookIds=Array.new
   # parsed_json = ActiveSupport::JSON.decode(params[:data])
  # message= parsed_json["userMessageData"]['message']
  # message_body = message
  # receiverIds=parsed_json["userMessageData"]['receiver_ids']
#    
  # receiverIds.each_with_index do |receiver,index|
      # user = User.find(receiverIds[index])
      # receiver_chat_id = "-#{user.fb_id}@chat.facebook.com"
# jabber_message = Jabber::Message.new(receiver_chat_id, message_body)
# jabber_message.subject = message_subject
# client = Jabber::Client.new(Jabber::JID.new(sender_chat_id))
# client.connect
# puts jabber_message
# client.auth_sasl(Jabber::SASL::XFacebookPlatform.new(client,'641206265895621', 'CAAJHLHe02sUBAMeCXVciZCT0gncHHRhvDQ71KsaI9ZAGXsjrJ0IGXWoUluPWxrwIhxuMRZCToIdJ528cOg1jYPZC48ZC6dYmeoWpeCpFquZBsZCdkG4Ia1e7aZCuZC6n3eEMF0UNQgxtb6tiOUGOFK538FUDThzpaLpcZD','e81cd8aa1272a4b3a17e3ac0824b07dc'), nil)
# client.send(jabber_message) 
# client.close
    # end
   
  end
  
  
  def callback_method
    puts current_user
  end
end