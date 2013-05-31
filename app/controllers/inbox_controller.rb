class InboxController < ApplicationController

  before_filter :check_users, :only => [:send_message]

  #reply the message, set a response into responses of the message sender, 
  #and fill the response object into the recipient user (parmas[:user_id])
  def reply

    #get replyer user
    @user = User.find(params[:user_id])
    @user.model_doc = @user.get_doc

    #get the sender id of the original message
    sender_id = @user.model_doc.messages[params[:original_message_id]]["original_message"]["sender_id"]

    #sender object
    @sender = User.find(sender_id)
    @sender.model_doc = @sender.get_doc

    #get the time, same time must be for sender and recipients
    response_time = Time.now

    @sender.model_doc.set("messages.#{params[:original_message_id]}.responses.#{params[:user_id]}",
    {:response_data => params[:response_data], :time => response_time})

    #fill the response field with the response_data
    @user.model_doc.set("messages.#{params[:original_message_id]}.response",
    {:response_data => params[:response_data], :time => response_time})

    
    #settings read and un read status, the recipient once answer it means read
    #the sender gets the answer, so mark the message as unread 
      
    @sender.model_doc.set("messages.#{params[:original_message_id]}.read_status","unread")

    @user.model_doc.set("messages.#{params[:original_message_id]}.read_status","read")

    respond_to do |format|
      format.json { render json: response_to_json({:updated_timestamp => Time.now})}
    end
  
  end

  #add the message to the :user_id as "sender" and recipients_ids as "recipient"
  def request_action
    original_message = {:sender_id => params[:user_id], :recipients_ids => params[:recipient_ids],
      :type => params[:type],:data => params[:data]}

    #find the sender by model_id
    @user = User.find(params[:user_id])
    @user.model_doc = @user.get_doc

    #generate mongo unique id, require because this id is across users
    message_id = BSON::ObjectId.from_time(Time.now)

    #adding the message into the sender
    @user.model_doc.set("messages.#{message_id}",{:owner_type => "sender", :responses => {},
      :original_message => original_message, :read_status => "read"})

    #adding the message into the recipents, using the same message_id !
    params[:recipient_ids].each do |rep_id|
      @user = User.find(rep_id)
      @user.model_doc = @user.get_doc
      @user.model_doc.set("messages.#{message_id}",{:owner_type => "recipient", :response => {},
        :original_message => original_message, :read_status => "unread"})
    end

    respond_to do |format|
      format.json { render json: response_to_json({:created_timestamp => Time.now}) }
    end

  end

  def reply_message

    #get user
    @user = User.find(params[:user_id])
    @user.model_doc = @user.get_doc

    if @user.model_doc.messages[params[:message_id]].nil?
      respond_to do |format|
        format.json { render json: response_to_json(nil,"user #{params[:user_id]} does not have the message # #{params[:message_id]}")}
      end
      return
    end

    #get the sender id of the original message
    original_sender_id = @user.model_doc.messages[params[:message_id]]["sender_id"]

    recipient_message = @user.model_doc.messages[params[:message_id]]
    if recipient_message["replies"].nil?
      recipient_message["replies"] = []
    end

    if original_sender_id.to_i == params[:user_id].to_i
      reply_receiver_id = @user.model_doc.messages[params[:message_id]]["receiver_id"].to_i
    else
      reply_receiver_id = original_sender_id.to_i
    end

    #on the reply the original sender id is going to be receiver
    recipient_message["replies"].push({:sent_date => Time.now.strftime('%Y/%m/%d - %H:%M:%S'),
      :sender_id => params[:user_id].to_i, :receiver_id => reply_receiver_id, :message => params[:reply]
    } )

    #update the message with the new answer 
    @user.model_doc.set("messages.#{params[:message_id]}",recipient_message)


    #the recipient message is replicated into sender and recipient
    @recipient = User.find(reply_receiver_id) 
    @recipient.model_doc = @recipient.get_doc

    #mark the message as un read
    recipient_message["read_date"] = nil

    #check if the recipient user has the message
    #it is crated on the first reply, so may doesn't have it
    @recipient.model_doc.set("messages.#{params[:message_id]}",recipient_message)

    respond_to do |format|
      format.json { render json: response_to_json(recipient_message)}
    end
   
  end

  def send_message
    #message sender id
    message_sender_id = BSON::ObjectId.from_time(Time.now)

    time = Time.now.strftime('%Y/%m/%d - %H:%M:%S')

    #create the sender_message
    sender_message = {:id => message_sender_id, :receiver_ids => params[:receiver_ids], :sent_date => time,
      :sender_id => params[:user_id].to_i, :stock_symbol => params[:stock_symbol],:message => params[:message]}

    #create the recipient message, lets leave the id and receiver_id empty because it can has many
    #recipients users
    recipient_message = {:id => nil, :receiver_id => nil, :read_date => nil, 
      :sent_date => time, :sender_id => params[:user_id].to_i, 
      :stock_symbol => params[:stock_symbol],:message => params[:message]}

    #find the sender by model_id
    @user = User.find(params[:user_id])
    @user.model_doc = @user.get_doc

    #adding the message into the sender
    @user.model_doc.set("messages.#{message_sender_id}",sender_message)

    #adding the message into the recipents, using the same message_id !
    params[:receiver_ids].each do |rep_id|
      @user_recipient = User.find(rep_id)
      @user_recipient.model_doc = @user_recipient.get_doc
      message_recipient_id = BSON::ObjectId.new()
      recipient_message["id"] = message_recipient_id
      recipient_message["receiver_id"] = rep_id.to_i
      @user_recipient.model_doc.set("messages.#{message_recipient_id}",recipient_message)
    end

    respond_to do |format|
      format.json { render json: response_to_json(sender_message) }
    end
  end

  def read
    #find the sender by model_id
    @user = User.find(params[:user_id])
    @user.model_doc = @user.get_doc

    if @user.model_doc.messages[params[:message_id]].nil?
      respond_to do |format|
        format.json { render json: response_to_json(nil,"user #{params[:user_id]} does not have the message # #{params[:message_id]}")}
      end
      return
    end
    message = @user.model_doc["messages"][params[:message_id]]
    message["read_date"] =  Time.now.strftime('%Y/%m/%d - %H:%M:%S')
    respond_to do |format|
      if @user.model_doc.set("messages.#{params[:message_id]}",message)
        format.json { render json: response_to_json(message) }
      else
        format.json { render json: response_to_json(nil,{:exeption => "message not update, exception"}) }
      end
    end

  end

   def delete
    #find the sender by model_id
    @user = User.find(params[:user_id])
    @user.model_doc = @user.get_doc

    if @user.model_doc.messages[params[:message_id]].nil?
      respond_to do |format|
        format.json { render json: response_to_json(nil,"user #{params[:user_id]} does not have the message # #{params[:message_id]}")}
      end
      return
    end
    @user.model_doc.unset("messages.#{params[:message_id]}")
    respond_to do |format|
        format.json { render json: response_to_json("Message Deleted") }
    end

  end

  def check_users
    userlist= []
    userlist.push(params[:user_id])
    params[:receiver_ids].each do |id|
      userlist.push(id)
    end if !params[:receiver_ids].nil?
    userlist.each do |id|
      begin
        User.find(id)
      rescue
        respond_to do |format|
          format.json { render json: response_to_json(nil,"the user #{id} does not exist"), status: :unprocessable_entity }
        end
      end
    end
  end
end
