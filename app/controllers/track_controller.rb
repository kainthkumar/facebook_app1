class TrackController < ApplicationController


  def index
  	if !$tracking_events[params[:event]].nil?
			@mixpanel.track_event($tracking_events[params[:event]])
		end
	  respond_to do |format|
      format.json { render json: response_to_json(:tracked => true)}
    end
  end
end
