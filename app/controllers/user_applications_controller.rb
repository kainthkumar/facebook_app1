class UserApplicationsController < ApplicationController
  # GET /user_applications
  # GET /user_applications.json
  def index
    @user_applications = UserApplication.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_applications }
    end
  end

  # GET /user_applications/1
  # GET /user_applications/1.json
  def show
    @user_application = UserApplication.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_application }
    end
  end

  # GET /user_applications/new
  # GET /user_applications/new.json
  def new
    @user_application = UserApplication.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_application }
    end
  end

  # GET /user_applications/1/edit
  def edit
    @user_application = UserApplication.find(params[:id])
  end

  # POST /user_applications
  # POST /user_applications.json
  def create
    @user_application = UserApplication.new(params[:user_application])

    respond_to do |format|
      if @user_application.save
        format.html { redirect_to @user_application, notice: 'User application was successfully created.' }
        format.json { render json: @user_application, status: :created, location: @user_application }
      else
        format.html { render action: "new" }
        format.json { render json: @user_application.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_applications/1
  # PUT /user_applications/1.json
  def update
    @user_application = UserApplication.find(params[:id])

    respond_to do |format|
      if @user_application.update_attributes(params[:user_application])
        format.html { redirect_to @user_application, notice: 'User application was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_application.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_applications/1
  # DELETE /user_applications/1.json
  def destroy
    @user_application = UserApplication.find(params[:id])
    @user_application.destroy

    respond_to do |format|
      format.html { redirect_to user_applications_url }
      format.json { head :no_content }
    end
  end
  
  def application_status
    user_id=params[:user]
    application_id=params[:application]
    userApp =  UserApplication.find_by_user_id_and_application_id(user_id,application_id)
     respond_to do |format|
       unless userApp.nil?
          format.json {render :json => {:valid => true }}
       else
         user_appObj=UserApplication.new
         user_appObj.user_id=user_id
         user_appObj.application_id=application_id
          user_appObj.save!
         format.json {render :json => {:valid => false,:user=>user_appObj.user_id}}
        end
     end
    
  end
end
