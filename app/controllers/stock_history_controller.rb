class StockHistoryController < ApplicationController
  def index
    begin
      #get response from stock_server, using configurations into config/settings.yml and request query into url
      response = RestClient.get "#{Rails.configuration.stock_server_url}/#{Rails.configuration.stock_history_controller}?#{URI.escape(request.query_string)}"
      
      #return response
      respond_to do |format|
        #parse response ( stock server returns json)
        format.json { render json:  response_to_json(ActiveSupport::JSON.decode(response.to_str))}
      end
    rescue RestClient::RequestFailed => e
      #return response in case of error, it can be 404 etc etc.
       respond_to do |format|
        format.json { render json:  response_to_json(nil,e.response)}
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render json:  response_to_json(nil,e.message)}
      end
    end
  end
end
