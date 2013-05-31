class AdminMailController < ApplicationController

	before_filter :check_session, :only => [:new,:create]


	def check_session
		redirect_to(:action => :index) if session[:user_admin].nil?
	end

  def index
    puts "i am in admin mail index with params"
  	if session[:user_admin].nil?
      redirect_to "http://www.facebook.com/dialog/oauth?client_id=#{$api_key}&redirect_uri=#{$fb_post_back}"
      return
    end
  	@emails = AdminEmail.where({})
  	respond_to do |format|
      format.html # show.html.erb
      format.json { render json: response_to_json(@emails) }
    end
  end

  def new
  	@email = AdminEmail.new
  	respond_to do |format|
      format.html # show.html.erb
    end
  end

  def create
  	@email = AdminEmail.new(params[:admin_email])
  	@email.admin_id = session[:user_admin].id
  	@email.sent_date = Time.now
    if @email.message_via == 'email'
      @users = User.find(:all)
      @users.each do |user|
        if !user.email.nil?
          AdminMailer.admin_mail(user,@email.message).deliver
        end
      end
      
    end
  	if @email.save()
  		flash[:message] = 'Email Created'
  		redirect_to(:action => :index)
  	end
  end


  def get
    @emails = AdminEmail.where({message_via: 'inbox'})
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: response_to_json(@emails) }
    end
  end




end
