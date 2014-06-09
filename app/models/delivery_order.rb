class DeliveryOrder < ActiveRecord::Base
  belongs_to :purchase_order 
end
