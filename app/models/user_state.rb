class UserState
  include Mongoid::Document
  field :model_id, type: Integer
  field :current_quest
  field :stocks
  field :map
  field :xp
  field :cash
  index({ model_id: 1 }, { unique: true, name: "model_index" })
  field :messages
end
