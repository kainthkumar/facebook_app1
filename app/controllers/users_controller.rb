class UsersController < ApplicationController
  
  before_filter :check_user, :except => [:index, :new,:create]


  $default_document = {model_id: 0, cash_rewarded: 0 ,cash: Rails.configuration.start_cash, 
          xp: Rails.configuration.start_exp,map: Rails.configuration.start_map, 
          stocks: Rails.configuration.start_stocks,current_quest: Rails.configuration.start_quest,
          messages: {}, quests: {}, stats: {}, notifications: {} }

  # GET /users
  # GET /users.json
  def index
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: response_to_json(@users) }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    puts "i am in user show eith params#{params}"
    @user = User.find(params[:user_id])

    @user.model_doc = @user.get_doc

    if params[:visit]
      @mixpanel.track_event("User Visits Friends Stockyard")
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: response_to_json( 
                                { :created_at => @user.created_at, 
                                  :fb_id => @user.fb_id, 
                                  :email => @user.email,  
                                  :facebook_token => @user.facebook_token, 
                                  :id => @user.id,
                                  :image_url => "#{Rails.configuration.open_graph_url}#{@user.fb_id}/picture?type=large",
                                  :stockyard_name => @user.stockyard_name, 
                                  :model_doc => @user.model_doc, 
                                  :level => @user.get_level
                                }
                              )
                  }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:user_id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new()
    @user.facebook_token = params[:facebook_token]
    @user.date_token_updated = Time.now
    @user.stockyard_name = params[:stockyard_name]
    if @user.save()
      @state = UserState.new({model_id: @user.id, cash: Rails.configuration.start_cash, 
        xp: Rails.configuration.start_exp,map: Rails.configuration.start_map, 
        stocks: Rails.configuration.start_stocks,current_quest: Rails.configuration.start_quest}).save()
      @user.model_doc = @user.get_doc
      respond_to do |format|
        format.json { render json: response_to_json({:created_at => @user.created_at, 
          :facebook_token => @user.facebook_token, :id => @user.id, :stockyard_name => @user.stockyard_name,
          :model_doc => @user.model_doc})}
      end
    else
      respond_to do |format|
        format.json { render json: response_to_json(nil,@user.errors), status: :unprocessable_entity }
      end
    end

  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:user_id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.json { render json: response_to_json({:update_timestamp => Time.now}) }
      else
        format.json { render json: response_to_json(nil,@user.errors) }
      end
    end
  end

  def reset
    @user = User.find(params[:user_id])
    @user.model_doc = @user.get_doc
    $default_document["model_id"] = @user.id
    if @user.model_doc.nil?
     flat = @state = UserState.new($default_document).save()
    else
     flat = @user.model_doc.update_attributes(@user.document)
    end
    respond_to do |format|
      if flat
        format.json { render json: response_to_json({:update_timestamp => Time.now}) }
      else
        format.json { render json: response_to_json(nil,@user.errors) }
      end
    end
  end



  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:user_id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def update_doc
    respond_to do |format|
      begin

        @user = User.find(params[:user_id])
        @user.model_doc = @user.get_doc
        params[:$inc].each { |key,obj| @user.model_doc.inc(key, obj) } if !params[:$inc].nil?
        params[:$set].each { |key,obj|
          
          if obj.kind_of?(Hash)
            obj = self.update_stock_purchase_price(@user,obj)
            self.update_user_stocks(obj) 
          end

          @user.model_doc.set(key, obj)
         
        } if !params[:$set].nil?
        params[:$unset].each { |key,obj|
          @user.model_doc.unset(key)
          self.update_user_stocks(key,'unset')  
        } if !params[:$unset].nil?
        format.json { render json: response_to_json({:update_timestamp => Time.now}) }
      rescue Exception => e
        format.json { render json: response_to_json(nil, {:message => e.message, :backtrace => e.backtrace}) }
      end

    end

  end

  def friends
    @user = User.find(params[:user_id])
    respond_to do |format|
      format.json { render json: response_to_json(@user.get_friends)}
    end
  end

  def update_user_stocks(object, type = 'set')
    user = params[:user_id]
    if type == 'set'
      if !object["stock_symbol"].nil?
        symbol = object["stock_symbol"]
        shares = object["transparent"].nil? ? object["shares"] : 0
        stock_id = object["stock_id"]
        type =  object["transparent"].nil? ? 'buy' : 'watch'
        if UserStocks.where("user_id = ? and stock = ? and type_stock = ?", user, symbol, type).exists?
          user_stock = UserStocks.where("user_id = ? and stock = ? and type_stock = ?", user, symbol, type).first()

          #get stocks difference
          difference = shares.to_i - user_stock.shares.to_i

          @event = Event.new()
          @event.user_id = user
          @event.event = "stock"
          @event.date = Date.today
          @event.save

          type_property = @event.event_properties.new()

          #if is positive it means we are buying more stocks 
          type_property.name = "type"

          if difference > 0
            type_property.value = "buy"
          elsif type != "watch"
            type_property.value = "sell"
          else
            type_property.value = "watch"
          end

          type_property.save

          stock_property = @event.event_properties.new()
          stock_property.name = "stock"
          stock_property.value = symbol
          stock_property.save

          shares_property = @event.event_properties.new()
          shares_property.name = "shares"
          shares_property.value = difference.to_i
          shares_property.save

          return user_stock.update_attributes({:stock => symbol, :shares => shares, :stock_id => stock_id})
        else
          user_stock = UserStocks.new()
          user_stock.stock = symbol
          user_stock.user_id = user
          user_stock.type_stock = type
          user_stock.shares = shares
          user_stock.stock_id = stock_id
          user_stock.save() 


          @event = Event.new()
          @event.user_id = user
          @event.event = "stock"
          @event.date = Date.today
          @event.save

          type_property = @event.event_properties.new()
          type_property.name = "type"
          type_property.value = type
          type_property.save

          stock_property = @event.event_properties.new()
          stock_property.name = "stock"
          stock_property.value = symbol
          stock_property.save

          shares_property = @event.event_properties.new()
          shares_property.name = "shares"
          shares_property.value = shares
          shares_property.save

          return true
        end
      end
    elsif type == 'unset'
      index = object.index('.')
      if !index.nil?
        stock = object[index+1, object.length]
      end
      record = UserStocks.where('user_id = ? and stock_id = ?', user, stock)
      record.each do |row|
        row.destroy
      end
    end
      
  end


  def notify
    begin
    #get user
    @user = User.find(params[:user_id])
    @user.model_doc = @user.get_doc

    @user.model_doc.set("notifications.#{params[:notification]}", true)
     respond_to do |format|
      format.json { render json: response_to_json({:updated => true})}
    end
    rescue Exception => e
      respond_to do |format|
        format.json { render json: response_to_json(nil, {:message => e.message}) }
      end
    end
  end

  # the purchase price is updated with a formula,
  # calculing the medium purchase value
  def update_stock_purchase_price(user,object)
    
    if !object["stock_symbol"].nil? && (object["transparent"].nil? || object["transparent"] == 0) && (!object["shares"].nil? || object["shares"] != 0)
        
      #isn't this a new stock ?
      if !user.model_doc["map"][object["stock_id"]].nil?

        stock_record = user.model_doc["map"][object["stock_id"]]

        old_purchase_price = stock_record["purchase_price"].to_f
        old_shares = stock_record["shares"].to_i

        actual_purchase_price = object["purchase_price"].to_f
        actual_shares = object["shares"].to_i

        difference = actual_shares - old_shares

        #pp = (old_pp * gamreold_shares) +- (ac_pp * difference) / (old_shares + ac_shares)

        new_purchase_price = (old_purchase_price * old_shares)
        if difference > 0
          new_purchase_price += (actual_purchase_price * difference.abs)
        elsif difference != 0
          new_purchase_price -= (actual_purchase_price * difference.abs)
        end
        new_purchase_price /= actual_shares

        object["purchase_price"] = new_purchase_price

      end

    end

    return object

  end

end
