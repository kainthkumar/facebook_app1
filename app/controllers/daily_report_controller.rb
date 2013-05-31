class DailyReportController < ApplicationController
  def index
  	@user = User.find(params[:user_id])
    @user.model_doc = @user.get_doc
  	@report_d = DailyReport.where(user_id: params[:user_id].to_i).first()
    respond_to { |format|
      format.html
      format.json { render json: @report_d}
    }
  end
end
