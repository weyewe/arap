class StockAdjustmentDetail < ActiveRecord::Base
  belongs_to :stock_adjustment
  belongs_to :item 
end
