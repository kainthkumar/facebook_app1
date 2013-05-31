class SendMessagesController < ApplicationController
  # GET /send_messages
  # GET /send_messages.json
  def index
    @send_messages = SendMessage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @send_messages }
    end
  end

  # GET /send_messages/1
  # GET /send_messages/1.json
  def show
    @send_message = SendMessage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @send_message }
    end
  end

  # GET /send_messages/new
  # GET /send_messages/new.json
  def new
    @send_message = SendMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @send_message }
    end
  end

  # GET /send_messages/1/edit
  def edit
    @send_message = SendMessage.find(params[:id])
  end

  # POST /send_messages
  # POST /send_messages.json
  def create
    @send_message = SendMessage.new(params[:send_message])

    respond_to do |format|
      if @send_message.save
        format.html { redirect_to @send_message, notice: 'Send message was successfully created.' }
        format.json { render json: @send_message, status: :created, location: @send_message }
      else
        format.html { render action: "new" }
        format.json { render json: @send_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /send_messages/1
  # PUT /send_messages/1.json
  def update
    @send_message = SendMessage.find(params[:id])

    respond_to do |format|
      if @send_message.update_attributes(params[:send_message])
        format.html { redirect_to @send_message, notice: 'Send message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @send_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /send_messages/1
  # DELETE /send_messages/1.json
  def destroy
    @send_message = SendMessage.find(params[:id])
    @send_message.destroy

    respond_to do |format|
      format.html { redirect_to send_messages_url }
      format.json { head :no_content }
    end
  end
end
