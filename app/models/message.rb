class Message
  include Mongoid::Document
  field :owner_type
  field :original_mesage
  field :responses
end
