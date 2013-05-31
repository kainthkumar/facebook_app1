class GameSettingsController < ApplicationController
  def index
    json = File.read("#{Rails.root}/config/quiz.txt")
   
    respond_to { |format|
      format.json { render json: response_to_json(JSON.parse(json.to_s))}
    }
  end
end
