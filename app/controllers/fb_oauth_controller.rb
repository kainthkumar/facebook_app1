class FbOauthController < ApplicationController
  require 'rack'

  $admins = Array(YAML::load(File.open("#{RAILS_ROOT}/config/fb_admin_ids.yml"))[Rails.env]["fb_admin_ids"])
  #$canvas_page_name = Rails.configuration.canvas_page_name

  def index
    
    
    puts "i am in index with url#{params}"
    data = {}

    if !params[:signed_request].nil?
      data  = FBGraph::Canvas.parse_signed_request($api_secret, params[:signed_request])
      token = data["oauth_token"]   
    end 
#     
    # if data["user_id"].nil?
      # return self.authorize
    # end
# 
    # client = FBGraph::Client.new(:client_id => $api_key,:secret_id =>$api_secret,
    # :token => token)
    # user_info = client.selection.me.info!
    # @user = User.where(:fb_id => user_info.id).first()
    # if not @user
      # @user          = self.create(token,user_info.first_name, user_info.id,user_info.email)
      # $new_user      = true
      # @mixpanel.track_event("Sign in")
      # @event         = Event.new()
      # @event.user_id = @user.id
      # @event.event   = "sign_up_date"
      # @event.date    = Date.today
      # @event.save
      # @user.get_friends_from_fb
    # else
      # @user.update_attributes({:facebook_token => token, :date_token_updated => Time.now})
    # end
# 
    # # add the session counter wheter is sign up or not
    # self.session_counter(@user.id)
# 
    # if $admins.include? @user.fb_id.to_i
      # session[:user_admin] = @user
      # if params[:admin] 
        # redirect_to :controller => "admin_mail", :action => "index" 
        # return
      # end
    # end   
# 
    # # not sure where to put this but feel free to move it :)
    # #there you go 
    # @api_host = Rails.configuration.host_app
     # respond_to do |format|
        # format.html {render 'index'}
    # end
  end


   def session_counter(user_id)
    #validate if the user alrady has this the session counter record
    @event = Event.find(:first, :conditions => {:user_id => user_id,:event => "session_start", 
      :date => Date.today})
    
    if @event.nil?
      #so lets create the event
      @event = Event.new()
      @event.user_id = user_id
      @event.event = "session_start"
      @event.date = Date.today
      @event.save
      #and make sure add the event property visits_number
      property = @event.event_properties.new()
      property.name = "session_counter"
      property.value = 1
      property.save
    else
      property = @event.event_properties.where(:name => "session_counter").first()
      property.update_attributes({:value => property.value.to_i + 1})
      property.save
    end 

  end

  def authorize
    @url = "http://www.facebook.com/dialog/oauth?client_id=#{$api_key}&redirect_uri=#{$fb_post_back}"
    puts "facebook_client#{facebook_client}"
    # content = open(URI.encode('https://graph.facebook.com/me?access_token=' + session[:access_token]))
    # content = ActiveSupport::JSON.decode(content)
    respond_to do |format|
      format.html { render :template => "fb_oauth/authorize" }
    end
  end


  def show
    @user = User.find(:first)
    self.session_counter(@user.id)


    @mixpanel.track_event("Sign in")
    if $admins.include? @user.fb_id.to_i
      session[:user_admin] = @user
      if params[:admin] 
        redirect_to :controller => "admin_mail", :action => "index" 
        return
      end
    end   

     respond_to do |format|
        format.html {render 'index'}
    end
  end

  protected
  def create(token,stockyard,fb_id,email)
    @user = User.new()
    @user.facebook_token = token
    @user.date_token_updated = Time.now
    @user.stockyard_name = stockyard
    @user.fb_id = fb_id
    @user.email = email
    if @user.save()
      @state = UserState.new({model_id: @user.id, cash: Rails.configuration.start_cash,
        xp: Rails.configuration.start_exp,map: Rails.configuration.start_map,
        stocks: Rails.configuration.start_stocks,current_quest: Rails.configuration.start_quest}).save()
      @user.model_doc = @user.get_doc
    end
    return @user
  end

end
