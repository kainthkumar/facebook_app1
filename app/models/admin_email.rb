class AdminEmail
  include Mongoid::Document
  field :message
  field :admin_id
  field :sent_date
  field :message_via

end
