class DailyReport
  include Mongoid::Document
  field :user_id
  field :stocks_balance
  field :watch_list_scores
end
