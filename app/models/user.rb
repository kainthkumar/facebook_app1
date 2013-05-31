class User < ActiveRecord::Base
  belongs_to :quest
  has_many :friendrelationships
  has_many :events
  attr_accessor :model_doc
  #accepts_nested_attributes_for :model_doc
  validates :stockyard_name,:facebook_token, :presence => true
  attr_accessible :facebook_token, :date_token_updated

  def document
     default_document = {model_id: self.id, cash_rewarded: 0 , cash: Rails.configuration.start_cash, 
          xp: Rails.configuration.start_exp,map: Rails.configuration.start_map, 
          stocks: Rails.configuration.start_stocks,current_quest: Rails.configuration.start_quest,
          messages: {}, quests: {}, stats: {}, notifications: {} }
     return default_document
  end

  def get_doc
    self.model_doc = UserState.where(model_id: self.id).first()
    if self.model_doc.nil?
       return self.create_default_doc
    end
    return self.model_doc  
  end


  #return an array with all user's friends

  def get_friends

  	friend_documents = []

  	self.friendrelationships.each do |friend|

  		friend_object = User.where(id: friend.friend_id).first()

  		friend_object.model_doc = friend_object.get_doc
  		
      friend_documents.push(
                            { :user_id => friend.friend_id.to_i, 
                              :name => friend_object.stockyard_name,
                              :fb_id => friend_object.fb_id, 
                              :xp => friend_object.model_doc.xp, 
                              :total_assets => friend_object.model_doc.cash + friend_object.get_total_in_stocks,
  			                      :image_url => "#{Rails.configuration.open_graph_url}#{friend_object.fb_id}/picture?type=large", 
  			                      :level => self.get_level(friend_object.model_doc.xp),
                              :dummy => friend_object.is_dummy?
                            })
  	end

  	return friend_documents
  end

  def get_friend_ids
    friend_ids = []
    self.friendrelationships.each do |friend|
      friend_ids.push(friend.friend_id)
    end
    return friend_ids
  end

  def get_level(exp=nil,index = 0)
  	exp = exp.nil? ? self.get_doc.xp : exp
  	exp = exp.nil? ? 0 : exp
  	
  	(index >= $level_exp.length || exp <= $level_exp[index] ) ? index+1 :	self.get_level(exp, index+1)
  end

  def create_default_doc
      user_document = UserState.new(self.document)
      user_document.save()
      return user_document
  end


  def get_total_in_stocks
    total = 0
    symbol_list = []
    shares_list = {}

    self.model_doc = self.get_doc
    self.model_doc.map.each do |obj_key, obj_value|
      symbol_list.push(obj_value["stock_symbol"])
      shares_list[obj_value["stock_symbol"]] = obj_value["shares"]
    end if self.model_doc.map

    total_amont = 0
    #if the user has stocks
    if !symbol_list.empty?      
      server = Rails.configuration.stock_server_url
      controller = Rails.configuration.stock_realtime_controller
      params = "?query[]=#{symbol_list.join('&query[]=')}"

      response = RestClient.get "#{server}/#{controller}/price#{params}"
      scores = ActiveSupport::JSON.decode(response)
      scores.each do |symbol,score|  
          total_amont += shares_list[symbol].to_i * score
      end
    end

    return total_amont
  end

  def document_to_hash
    hash = {}; self.model_doc.attributes.each { |k,v| hash[k] = v }
    return hash
  end

  def is_dummy?
    self.fb_id.to_s == Rails.configuration.dummy_id.to_s
  end

  def get_purchased_stocks
    symbol_list = []

    self.model_doc = self.get_doc
    self.model_doc.map.each do |obj_key, obj_value|
      symbol_list.push({:symbol => obj_value["stock_symbol"], 
                   :shares => obj_value["shares"],
                   :purchase_price => obj_value["purchase_price"],
                   :total_invested => (obj_value["shares"].to_i * obj_value["purchase_price"].to_f).round(2),
                   :user_id => self.id,
                   :stockyard_name => self.stockyard_name
      }) if !obj_value["purchase_price"].nil?
    end if self.model_doc.map

    return symbol_list
  end

  def get_friends_from_fb
    begin
    server = Rails.configuration.open_graph_url
     #facebook query to get friends who play the same game
    fql_query = "select uid, name, is_app_user 
                from user 
                where uid in 
                (select uid2 from friend where uid1=me()) 
                and is_app_user=1"
    json_response = RestClient.get "#{server}fql", :params => {:q => fql_query, 
                    :access_token => self.facebook_token}

    response_friends = ActiveSupport::JSON.decode(json_response.to_str)
      if response_friends["data"]
        friend_list = []
        self.friendrelationships.each do |uf|
            friend_list.push(uf.friend_id)
        end
        #hardcode default friend
        response_friends["data"].push({"uid" => Rails.configuration.dummy_id,
                                       "name" => Rails.configuration.dummy_name,
                                       "is_app_user" => true})
        response_friends["data"].each do |friend|
          friend_object = User.where(:fb_id => friend["uid"]).first()
          #if the friend from facebook is not on my friend list
          #so add the relationship
          if !friend_object.nil?
            if !friend_list.include?(friend_object.id.to_s)
              new_friend = Friendrelationship.new()
              new_friend.user_id = self.id
              new_friend.friend_id = friend_object.id
              new_friend.save()
              reversive_friend = Friendrelationship.new()
              reversive_friend.user_id = friend_object.id
              reversive_friend.friend_id = self.id
              reversive_friend.save()
            end
          end

        end
    end
    rescue RestClient::RequestFailed => e
      Rails.logger.error "#{e.response} user #{self.id}"
    rescue Exception => e
      Rails.logger.error "#{e.message} #{e.backtrace} user #{self.id}"
    end
  end


end