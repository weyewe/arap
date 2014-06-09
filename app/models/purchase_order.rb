class PurchaseOrder < ActiveRecord::Base
  has_many :purchase_receivals  
end
