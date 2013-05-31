class EventProperty < ActiveRecord::Base
	belongs_to :event

	attr_accessible :event_id, :name, :value
end
