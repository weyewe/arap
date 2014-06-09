class StockAdjustment < ActiveRecord::Base
  has_many :stock_adjustment_details 
end
