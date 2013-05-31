class StockRealtimeController < ApplicationController
  def index
    # puts "params is #{params}"
    begin

    #get response from stock_server, using configurations into config/settings.yml and request query into url
    response = RestClient.get "#{Rails.configuration.stock_server_url}/#{Rails.configuration.stock_realtime_controller}?#{URI.escape(request.query_string)}"
    # puts "response#{response}"
    response_stocks = ActiveSupport::JSON.decode(response.to_str)
    
    response_stocks = check_filter_stocks(response_stocks)
  
    #return response
      respond_to do |format|
        #parse response ( stock server returns json)
        format.json { render json:  response_to_json(response_stocks)}
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
  def custom_method
    puts "in custom  method"
  end

  def category
    begin
      #get response from stock_server, using configurations into config/settings.yml and request query into url
      response = RestClient.get "#{Rails.configuration.stock_server_url}/#{Rails.configuration.stock_realtime_controller}/category?#{request.query_string}"
      
      #return response
      respond_to do |format|
        #parse response ( stock server returns json)
        format.json { render json:  response_to_json(ActiveSupport::JSON.decode(response.to_str))}
      end
    rescue => e
      #return response in case of error, it can be 404 etc etc.
       respond_to do |format|
        format.json { render json:  response_to_json(nil,e.response)}
      end
    end
  end


  #custom function for getting watch and buy for each requested symbol
  # example request : stock-realtime/popular?query[]=FB
  # example response: "FB": { "watch": 1,"buy": 1 }
  def get_filter_details(stocks = nil )
    friend_ids = [6]
    if !params[:user_id].nil?
      friend_ids = []
      user = User.find(params[:user_id]) 
      friend_ids = user.get_friend_ids
    end

    stocks = stocks.nil? ? params[:query] : stocks

    sql_query = "SELECT stock, sum(watch) AS watch, sum(buy) AS buy, sum(friends_buy) as 
                friends_buy, sum(friends_watch) as friends_watch
                FROM 
                (
                  (SELECT stock, count(stock) AS watch, 0 AS buy, 0 as friends_buy, 0 as friends_watch
                  FROM user_stocks
                  WHERE type_stock = 'watch' GROUP BY stock)
                  UNION ALL
                  (SELECT stock,0 AS watch, count(stock) AS buy, 0 as friends_buy, 0 as friends_watch
                  FROM user_stocks 
                  WHERE type_stock = 'buy'  GROUP BY stock)
                  UNION ALL
                  (SELECT stock,0 AS watch, 0 AS buy, count(stock) as friends_buy, 0 as friends_watch
                  FROM user_stocks 
                  WHERE type_stock = 'buy' and user_id in (?) GROUP BY stock)
                  UNION ALL
                  (SELECT stock,0 AS watch, 0 AS buy, 0 as friends_buy, count(stock) as friends_watch
                  FROM user_stocks 
                  WHERE type_stock = 'watch' and user_id in (?) GROUP BY stock)
                ) as table_merged
                WHERE table_merged.stock in (?)
                GROUP BY table_merged.stock"
    connect = ActiveRecord::Base.connection();
    most_popular = connect.execute(ActiveRecord::Base.send(:sanitize_sql_array, [sql_query,friend_ids,
                                                                                  friend_ids,stocks]))
    hash = {}
    max_f_buy = min_f_buy = max_f_watch = min_f_watch = max_buy = min_buy = 0
    most_popular.each do |v|

      hash_attributes = {}
      hash_attributes[:watch] = v[1].to_i
      hash_attributes[:buy] = v[2].to_i
      friends_buy = v[3].to_i
      friends_watch = v[4].to_i

      hash_attributes[:friends_buy] = friends_buy
      hash_attributes[:friends_watch] = friends_watch
      hash[v[0]] = hash_attributes


      max_f_buy = max_f_buy < friends_buy ? friends_buy : max_f_buy

      min_f_buy = friends_buy < min_f_buy ? friends_buy : min_f_buy

      max_f_watch = max_f_watch < friends_watch ? friends_watch : max_f_watch

      min_f_watch = min_f_watch > friends_watch ? friends_watch : min_f_watch

      max_buy = max_buy < hash_attributes[:buy] ? hash_attributes[:buy] : max_buy

      min_buy = max_buy > hash_attributes[:buy] ? hash_attributes[:buy] : min_buy

    end

    hash.each do |symbol, object|
      friends_popular = 0
      if object[:friends_buy] > 0
        friends_popular = object[:friends_buy] * (max_f_watch + (max_buy+1)) + 1
      elsif object[:friends_watch] > 0
        friends_popular = object[:friends_watch] + (max_buy+1)
      else
        friends_popular = object[:buy]
      end
      hash[symbol][:friends_popular] = friends_popular
    end

   return hash
  end

  def check_filter_stocks(response_stocks)
    requested_stocks = get_filter_details(params[:query])

    response_stocks.each do |stock, object|
      if !requested_stocks[stock].nil?
        object[:watch_popular] = requested_stocks[stock][:watch]
        object[:buy_popular] = requested_stocks[stock][:buy]
        object[:friends_buy] = requested_stocks[stock][:friends_buy]
        object[:friends_watch] = requested_stocks[stock][:friends_watch]
        object[:friends_popular] = requested_stocks[stock][:friends_popular]
      else
        object[:watch_popular] = 0        
        object[:buy_popular] = 0
        object[:friends_buy] = 0
        object[:friends_popular] = 0
      end
    end 

    return response_stocks
  end

  def fund
    begin

    friend_ids_str = ""
    if !params[:user_id].nil?
      friend_ids_str = get_friend_list_str(params[:user_id])
    end

    #get response from stock_server, using configurations into config/settings.yml and request query into url
    response = RestClient.get "#{$stock_server}/#{$realtime_controller}/fund?limit=#{params[:limit]}&order=#{params[:order]}#{friend_ids_str}"

    
    response_stocks = ActiveSupport::JSON.decode(response.to_str)
    
  
    #return response
      respond_to do |format|
        #parse response ( stock server returns json)
        format.json { render json:  response_to_json(response_stocks)}
      end
    rescue RestClient::RequestFailed => e
      #return response in case of error, it can be 404 etc etc.
       respond_to do |format|
        format.json { render json:  response_to_json(nil,e.response)}
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render json:  response_to_json(nil,e.backtrace)}
      end
    end
  end

   def foreign
    begin


    friend_ids_str = ""
    if !params[:user_id].nil?
      friend_ids_str = get_friend_list_str(params[:user_id])
    end

    #get response from stock_server, using configurations into config/settings.yml and request query into url
    response = RestClient.get "#{$stock_server}/#{$realtime_controller}/foreign?limit=#{params[:limit]}&order=#{params[:order]}#{friend_ids_str}"
    
    response_stocks = ActiveSupport::JSON.decode(response.to_str)
    
  
    #return response
    respond_to do |format|
        #parse response ( stock server returns json)
        format.json { render json:  response_to_json(response_stocks)}
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

  def all
    begin


    friend_ids_str = ""
    if !params[:user_id].nil?
      friend_ids_str = get_friend_list_str(params[:user_id])
    end

    #get response from stock_server, using configurations into config/settings.yml and request query into url
    response = RestClient.get "#{$stock_server}/#{$realtime_controller}/all?limit=#{params[:limit]}&order=#{params[:order]}#{friend_ids_str}"
    
    response_stocks = ActiveSupport::JSON.decode(response.to_str)
     
  
    #return response
    respond_to do |format|
        #parse response ( stock server returns json)
        format.json { render json:  response_to_json(response_stocks)}
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

  protected
  def get_friend_list_str(user_id)
    friend_ids_str = ''
    friend_ids = []
    user = User.find(user_id) 
    friend_ids = user.get_friend_ids
    friend_ids.each_with_index do |id,index|
      friend_ids_str += "&friend_list[]=#{id}"
    end
    return friend_ids_str
  end

end
