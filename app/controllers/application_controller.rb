class ApplicationController < ActionController::Base
  protect_from_forgery


  before_filter :initialize_mixpanel
  $level_exp = [20,40,90,200,350,550,800,1300,1800,2300,2800,3300,3900,4500,5500,6500,7500,
                  8500,9500,11500,13500,15500,17500,20500,25000]
  def initialize_mixpanel
    @mixpanel = Mixpanel::Tracker.new(Rails.configuration.mixpanel_token, request.env, {:persist => true})
  end 

  attr_accessor :error_handle
  $new_user = false
  $user_token="0123abc"
  $api_key = Rails.configuration.api_key
  $api_secret = Rails.configuration.secret_key
  $fb_post_back = Rails.configuration.fb_callback_url
  $stock_server = Rails.configuration.stock_server_url
  $realtime_controller = Rails.configuration.stock_realtime_controller
  $tracking_events = {"complete_quest" => "User Completes Quest",
    "complete_task" => "User Completes Task", "complete_quiz" => "User Completes Quiz",
    "add_friend" => "User Adds Friend", "ask_tip" => "User Asks For A Tip",
    "response_tip" => "User Responds Tip", "response_message" => "User Response Message"
  }

  class Response_Object
    attr_accessor :error, :http_code, :resquest_id, :response
  end

  def response_to_json(json_response,error = nil)
    @resp = Response_Object.new
    @resp.response = json_response
    @resp.error = error
    @resp.resquest_id = request.uuid
    @resp.http_code = response.status
    return @resp
  end
   def current_user
     puts session[:id]
   end
  def check_user
    begin
      User.find(params[:user_id])
    rescue
      respond_to do |format|
        format.json { render json: response_to_json(nil,'User does not exist'), status: :unprocessable_entity }
      end
    end
  end
  private
  
  # def current_user
    # puts "i am in current user with params#{session[:user_id]}"
#   
  # @current_user ||= User.find(session[:user_id]) if session[:user_id]
# end

end