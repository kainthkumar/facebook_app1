class Event < ActiveRecord::Base
  belongs_to :user
	has_many :event_properties

	attr_accessible :user_id, :event, :date
	attr_accessor :stockyard_name

	def self.get_event_by_user_and_date(user_id,event,date)
		Event.find(:first, :conditions => {:user_id => user_id,
								:event => event, :date => date})
	end

	def self.get_event_by_user(user_id,event)
		Event.find(:first, :conditions => {:user_id => user_id,
								:event => event})
	end

	def self.get_events(event)
		Event.find(:all, :conditions => {:event => event})
	end

	def get_playtime_event(user_id,event,session_number)
		Event.find(:first, 
		            :joins => "LEFT JOIN `event_properties` ON event_properties.event_id = events.id",
		            :conditions => {:user_id => user_id,
								:event => event })
	end

end
