class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index

    respond_to do |format|
      format.html # index.html.erb
    end
  end


  # GET /events/1
  # GET /events/1.json
  def show

    @events = Event.get_events(params[:event_name])

    @row = Array.new()

    @events.each do |event|
        hash = {}
        hash[:date] = event.date
        hash[:user_id] = event.user_id
        hash[:event] = event.event.split('_').join(' ').capitalize!
        hash[:stockyard_name] = event.user.stockyard_name
        event.event_properties.each do |property|
          hash[property[:name]] = property[:value]
        end
        @row << hash
    end

    respond_to do |format|
      format.json { render json: @row }
      format.csv { self.to_csv(@row) }
    end
  end

  def user_level
    @user_rows = []
    @users = User.find(:all)
    @users.each do |user|
      user.model_doc = user.get_doc
      Rails.logger.info(user.model_doc)
      @user_rows.push({
                      :user_id => user.id, 
                      :stockyard_name => user.stockyard_name, 
                      :xp => user.model_doc.xp, 
                      :level => user.get_level 
                      })
    end

     respond_to do |format|
      format.json { render json: @user_rows }
      format.csv { self.to_csv(@user_rows) }
    end

  end

  def to_csv(body)
    respond_to do |format|
      format.csv {
       csv_data = CSV.generate do |csv_data|
          flag = false
          body.each do |line|
            line_s = []
            if !flag
              # add the headers
              line.each do |key,val|
                line_s.push(key.to_s)
              end
              csv_data << line_s
              line_s = []
              flag = true
            end
            line.each do |key,val|
              line_s.push(val)
            end
            csv_data << line_s
          end
        end
        send_data csv_data, :filename => "#{params[:action]}.csv"
      }
    end
  end

  def stock_report
    
    @users = User.all

    @row = Array.new()

    @users.each do |user|
      user_array = user.get_purchased_stocks
      @row.concat(user_array) if !user_array.empty?
    end

    respond_to do |format|
      format.json { render json: @row }
      format.csv { self.to_csv(@row) }
    end
  end

  def post_play_time
    #validate if the user already has played
    @event = Event.get_event_by_user(params[:user_id], params[:event])

    if @event.nil?
      #so lets create the event
      @event = Event.new()
      @event.user_id = params[:user_id]
      @event.event = params[:event]
      @event.date = Date.today
      @event.save
      #and make sure add the event property visits_number
      property = @event.event_properties.new()
      property.name = "minutes"
      property.value = 1
      property.save
    else
      property = @event.event_properties.where(:name => "minutes").first()
      property.update_attributes({:value => property.value.to_i + 1})
      property.save
    end 

    respond_to do |format|
      format.json { render json: @event }
    end
  end

  def portolio_invested
    @user_rows = []
    @users = User.find(:all)
    @users.each do |user|
      user.model_doc = user.get_doc
      total_asset = user.get_total_in_stocks + user.model_doc.cash
      invested = total_asset - user.model_doc.cash
      invested = invested.abs / total_asset if total_asset != 0 
      invested *= 100
      @user_rows.push({:user_id => user.id, :stockyard_name => user.stockyard_name,
       :total_assets => total_asset.round(3), :cash => user.model_doc.cash.round(3),
       :invested => invested.round(3) } )
    end

     respond_to do |format|
      format.json { render json: @user_rows }
      format.csv { self.to_csv(@user_rows) }
    end
  end

  def show_quest 
    @events = Event.find(:all, :include => :event_properties, :conditions =>{ event: "quest"})
    

    @row = Array.new()

    @events.each do |event|
        hash = {}
        hash[:date] = event.date
        hash[:stockyard_name] = event.user.stockyard_name
        event.event_properties.each do |property|
          hash[property[:name]] = property[:value]
        end
        @row << hash
    end

    respond_to do |format|
      format.json { render json: @row }
      format.csv { self.to_csv(@row) }
    end
  end

 def friends_joined
  @user_rows = []
  @users = User.find(:all)
  @users.each do |user|
    
    @user_rows.push({:user_id => user.id, :stockyard_name => user.stockyard_name,
                    :friends_number => user.friendrelationships.count})

  end

  respond_to do |format|
    format.json { render json: @user_rows }
    format.csv { self.to_csv(@user_rows) }
  end

 end


  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create

    #avoid the routes mapping

    return self.visit_market      if params[:event]  == 'visit_market'
    
    return self.visit_friend       if params[:event] == 'visit_friend'
    
    return self.visit_dummy        if params[:event] == 'visit_dummy'
    
    return self.post_play_time     if params[:event] == 'playtime'
    
    return self.post_invite_friend if params[:event] == 'invite_friend'


    @event = Event.new()
    @event.user_id = params[:user_id]
    @event.event = params[:event]
    @event.date = Date.today

    respond_to do |format|
      if @event.save
        params[:properties].each do |key,value|
          property = @event.event_properties.new()
          property.name = key
          property.value = value
          property.save
        end if !params[:properties].nil?

        format.json { render json: @event, status: :created}
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end


  def post_invite_friend
    @event = Event.get_event_by_user(params[:user_id], params[:event])
    
    if @event.nil?
      #so lets create the event
      @event = Event.new()
      @event.user_id = params[:user_id]
      @event.event = params[:event]
      @event.date = Date.today
      @event.save
      #and make sure add the event property visits_number
      property = @event.event_properties.new()
      property.name = "friend_number"
      property.value = params[:properties][:number]
      property.save
    else
      property = @event.event_properties.where(:name => "friend_number").first()
      property.update_attributes({:value => property.value.to_i + params[:properties][:number]})
      property.save
    end 

    respond_to do |format|
      format.json { render json: @event, status: :created }
      format.csv { self.to_csv(@event) }
    end

  end


  def visit_market
    #validate if the user alrady has this the visit market record
    @event = Event.get_event_by_user(params[:user_id],params[:event])
    
    if @event.nil?
      #so lets create the event
      @event = Event.new()
      @event.user_id = params[:user_id]
      @event.event = params[:event]
      @event.date = Date.today
      @event.save
      #and make sure add the event property visits_number
      property = @event.event_properties.new()
      property.name = "visits_number"
      property.value = 1
      property.save
    else
      property = @event.event_properties.where(:name => "visits_number").first()
      property.update_attributes({:value => property.value.to_i + 1})
      property.save
    end 

    respond_to do |format|
      format.json { render json: @event, status: :created }
      format.csv { self.to_csv(@event) }
    end

  end


  def visit_friend
    today = Date.today

    #validate if the user already visit_friend
    @event = Event.find(:first, :conditions => {:user_id =>  params[:user_id],
      :event => params[:event], :date => today})

    if @event.nil?
      #so lets create the event
      @event = Event.new()
      @event.user_id = params[:user_id]
      @event.event = params[:event]
      @event.date = today
      @event.save
      #and make sure add the event property visits_number
      property = @event.event_properties.new()
      property.name = "friends_visits_number"
      property.value = 1
      property.save
    else
      property = @event.event_properties.where(:name => "friends_visits_number").first()
      property.update_attributes({:value => property.value.to_i + 1})
      property.save
    end 

    respond_to do |format|
      format.json { render json: @event, status: :created }
    end
  end



  #first time the user visited dummy friend
  
  def visit_dummy
    today = Date.today
    #validate if the user visit_dummy
    @event = Event.get_event_by_user(params[:user_id], params[:event])

    if @event.nil?
      #so lets create the event
      @event = Event.new()
      @event.user_id = params[:user_id]
      @event.event = params[:event]
      @event.date = today
      @event.save
    end 

    respond_to do |format|
      format.json { render json: @event, status: :created }
    end
  end

  # PUT /events/1ruler 
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
end
