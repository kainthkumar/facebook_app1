namespace :report do
  require 'scruffy'
  class CustomTheme < Scruffy::Themes::Base
    def initialize
     super({:background => ['#C6C6AA','#C6C6AA'],
       :market => '#00000',
       :colors => %w(#0033CC #0033CC #0033CC #0033CC #0033CC #0033CC #0033CC #0033CC #0033CC)
     })
    end
  end

  def reset_time
    return "8:00:00"
  end

  def get_scores(symbol_list)
    puts symbol_list
   # response from historical controller
   server = Rails.configuration.stock_server_url
   controller = Rails.configuration.stock_history_controller
   params = "/report?query[]=#{symbol_list.join('&query[]=')}&start_date=#{Date.today}&end_date=#{Date.today+1}"

   json_response = RestClient.get "#{server}/#{controller}#{params}"

   response_historical = ActiveSupport::JSON.decode(json_response.to_str)

   return response_historical
  end

  def get_scores_realtime(symbol_list)
   # response from historical controller
   server = Rails.configuration.stock_server_url
   controller = Rails.configuration.stock_realtime_controller
   params = "/price?query[]=#{symbol_list.join('&query[]=')}"

   json_response = RestClient.get "#{server}/#{controller}#{params}"

   response = ActiveSupport::JSON.decode(json_response.to_str)

   return response
  end

  desc "Create daily Reports"
  task :daily_report => :environment do
    float_regex = /^(\+?((([0-9]+(\.)?)|([0-9]*\.[0-9]+))([eE][+-]?[0-9]+)?))$/
    #get all users
    @users = User.find(:all).each do |user|
      begin
        #get the mongo document per each user
        user.model_doc = user.get_doc
        report_flag = false

        #user has model_doc from mongo
        watch_list = []
        symbol_list = []
        symbol_info = {}


        if user.model_doc
     
          #get all ids from stocks if the user has maps elements
          user.model_doc.map.each do |obj_key, obj_value|

            if ( obj_value["transparent"].nil? || obj_value["transparent"] == 0) && obj_value["shares"] != 0
              symbol_list.push(obj_value["stock_symbol"])
              symbol_info[obj_value["stock_symbol"]] = {:shares => obj_value["shares"], 
                :purchase_price => obj_value["purchase_price"]}
            elsif !obj_value["transparent"].nil? && obj_value["transparent"] == 1
              watch_list.push(obj_value["stock_symbol"])
            end
    
        end if user.model_doc.map

        stock_historical = get_scores(symbol_list)

        watch_historical = get_scores(watch_list)
        #historical cron runs after the market closes
        #so the price returned is the close of the date
        symbol_scores = {}
        portfolio_gain = 0
        portfolio_price = 0
        report = {}
        watch_scores = {}

        stock_historical.each do |symbol, dates|
          dates.each do |date, value|
            close = value["price"] =~ float_regex ? Float(value["price"]) : 0
            open = value["previous_close"] =~ float_regex ? Float(value["previous_close"]) : 0
            shares = symbol_info[symbol][:shares]
            purchase_price = symbol_info[symbol][:purchase_price].nil? ? 0 : symbol_info[symbol][:purchase_price]

            #daily values
            daily_gain_amount = close - open

            daily_gain_porcent = close != 0 ? (daily_gain_amount * 100 / open) : 0

            daily_gain_amount *= shares
            
            
            #general values, calculated with the historical price when I bought the stock
            value_gain_amount = close - purchase_price
            value_gain_porcent = value_gain_amount * 100 / open
            value_gain_amount *= shares
            

            symbol_scores[symbol] = { 
                                      :latest_price => close, 
                                      :daily_gain_amount => daily_gain_amount.round(2),
                                      :daily_gain_porcent => daily_gain_porcent.round(2), 
                                      :value_gain_amount => value_gain_amount.round(2),
                                      :value_gain_porcent => value_gain_porcent.round(2), 
                                      :shares => shares  
                                    }
 
            portfolio_gain += daily_gain_amount
            portfolio_price += (close * shares)
          end
        end if !stock_historical.empty?
        

        watch_historical.each do |symbol, dates|
          dates.each do |date, value|
            close = value["price"] =~ float_regex ? Float(value["price"]) : 0
            open = value["previous_close"] =~ float_regex ? Float(value["previous_close"]) : 0

            #daily values
            daily_gain_amount = close - open
            daily_gain_porcent = close != 0 ? (daily_gain_amount * 100 / open) : 0
          
            watch_scores[symbol] = { 
                                    :latest_price => close, 
                                    :daily_gain_amount => daily_gain_amount.round(2),
                                    :daily_gain_porcent => daily_gain_porcent.round(2)
                                  }
          end
        #requirement: 
        #do not calculate the watch list if the users does not have stocks
        end if !watch_historical.empty? && !stock_historical.empty?

        dao_report = DailyReport.where(user_id: user.id).first()
         report = {
                    :user_id => user.id, 
                    :date =>Date.today().strftime("%Y-%m-%d"),
                    :stocks_balance => {},
                    :watch_list_scores => {},
                    :enable => false
                  }

        if !symbol_scores.empty? || !watch_scores.empty?
          if portfolio_price == 0
            portfolio_change = 0
          else
            portfolio_change = portfolio_gain * 100 / (portfolio_price + portfolio_gain)
          end
  

            report[:portfolio_price] = portfolio_price.round(2)
            report[:portfolio_gain] = portfolio_gain.round(2)
            report[:portfolio_change] = portfolio_change.round(2)
            report[:stocks_balance] = symbol_scores
            report[:watch_list_scores] = watch_scores
            report[:enable] = true


            #at this at historical report event

            @event = Event.new()
            @event.user_id = user.id
            @event.event = "historical_performance"
            @event.date = Date.today
            @event.save

            #add the properties
            event_properties = [{:name => "bank_amount", :value => user.model_doc["cash"].round(2)},
                                {:name => "portfolio_price", :value => portfolio_price.round(2)},
                                {:name => "portfolio_gain", :value => portfolio_gain.round(2)},
                                {:name => "portfolio_change", :value => portfolio_change.round(2)}
                              ]
            event_properties.each do |p|
              property = @event.event_properties.new()
              property.name = p[:name]
              property.value = p[:value]
              property.save
            end                  
            

        else
          report_flag = true
        end

        #mark the performance report as unread
        #unless the user does not have performance report
        user.model_doc.set("notifications.performance_report",report_flag)
        user.model_doc.save

        if dao_report.nil?
          dao_report = DailyReport.new(report)
          dao_report.save()
        else
          report[:portfolio_balance] = dao_report["portfolio_balance_progress"]
          dao_report.update_attributes(report)
        end
        dao_report = clean_portfolio_balance(dao_report)
        dao_report.save()


        if !dao_report[:portfolio_balance].nil?
          times = []
          values = []
          dao_report[:portfolio_balance].each do |object|
            times.push(object["time"])
            values.push(object["portfolio_price"])
          end


          graph = Scruffy::Graph.new(:title => "Portfolio Value",:theme => CustomTheme.new)
          graph.title = "Portfolio Value"

          graph.renderer = Scruffy::Renderers::Standard.new()
          graph.value_formatter = Scruffy::Formatters::Currency.new(
                :special_negatives => true, :negative_color => '#ff7777')
          graph.add :line, 'Portfolio Value', values

          graph.point_markers = times

          graph.render(:width => 400,:height =>300,
                       :to => "#{Rails.root}/app/assets/images/#{user.id}_report.jpg",
                       :as => 'jpg')
        end
        


      end
      rescue Exception => e
        Rails.logger.error("#{e.message}  #{e.backtrace}")
      end

    end #ursh

  end


  task :portfolio_hourly => :environment do
    
      float_regex = /^(\+?((([0-9]+(\.)?)|([0-9]*\.[0-9]+))([eE][+-]?[0-9]+)?))$/
      #get all users
      @users = User.find(:all).each do |user|
        begin
        #get the mongo document per each user
        user.model_doc = user.get_doc
        #user has model_doc from mongo
        if user.model_doc
          symbol_list = []
          symbol_info = {}
          #get all ids from stocks if the user has maps elements
          user.model_doc.map.each do |obj_key, obj_value|
            if obj_value["transparent"].nil? && obj_value["shares"] != 0
              symbol_list.push(obj_value["stock_symbol"])
              symbol_info[obj_value["stock_symbol"]] = obj_value["shares"]
            end
          end if user.model_doc.map

          stock_historical = get_scores_realtime(symbol_list)

          #historical cron runs after the market closes
          #so the price returned is the close of the date

          portfolio_price = 0
          report = {}
          stock_historical.each do |symbol, value|
              close = value
              shares = symbol_info[symbol]
              portfolio_price += close * shares
          end

          dao_report = DailyReport.where(user_id: user.id).first()
          if !dao_report.nil?
            dao_report.push("portfolio_balance_progress", {:time => Time.now().strftime("%H:00"),
              :portfolio_price  => portfolio_price})
          else
            report["user_id"] = user.id
            report["date"] = Date.today().strftime("%Y-%m-%d")
            report["portfolio_balance"] = []
            report["portfolio_price"] = portfolio_price
            report["portfolio_balance_progress"] = []
            report["portfolio_balance_progress"].push({:time => Time.now().strftime("%H:00"),
              :portfolio_price  => portfolio_price})
            dao_report = DailyReport.new(report)
            dao_report.save()
          end

        end
        rescue Exception => e
          Rails.logger.error("#{e.message}  #{e.backtrace}")
        end
      end
    
  end

  def clean_portfolio_balance(dao_report)
    dao_report.unset(:portfolio_balance_progress)
    return dao_report
  end

end